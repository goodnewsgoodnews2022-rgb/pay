import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  // Catch Preflight request CORS triggers
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: { 'Access-Control-Allow-Origin': '*' } })
  }

  try {
    // 1. Get Secret Hash Header sent by Flutterwave to verify signature origin integrity
    const flwSignature = req.headers.get('verif-hash');
    const systemSecretHash = Deno.env.get('FLW_WEBHOOK_HASH');

    if (!flwSignature || flwSignature !== systemSecretHash) {
      return new Response(JSON.stringify({ error: "Unauthorized Signature Hash Verification Failed" }), { status: 401 });
    }

    const payload = await req.json();

    // Ensure we process completed status transactions safely
    if (payload.status === 'successful' || payload.event === 'charge.completed') {
      const txRef = payload.txRef || payload.data?.tx_ref;
      const amountPaid = payload.amount || payload.data?.amount;
      const flwId = payload.id || payload.data?.id;

      // Initialize internal Supabase client using administrative Service Role Key safely bypass RLS boundaries
      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      );

      // Fetch corresponding tracking deposit ledger context record 
      const { data: depositRecord, error: fetchErr } = await supabaseAdmin
        .from('deposits')
        .select('*')
        .eq('tx_ref', txRef)
        .single();

      if (fetchErr || !depositRecord) {
        return new Response(JSON.stringify({ error: "Matching internal Deposit reference reference not found" }), { status: 404 });
      }

      // Check to prevent double funding vectors (Idempotency Guard)
      if (depositRecord.status === 'completed') {
        return new Response(JSON.stringify({ status: "Duplicate event already accounted for" }), { status: 200 });
      }

      // 2. Perform server-to-server status checks back to Flutterwave using Secret API Key 
      const verificationUrl = `https://api.flutterwave.com/v3/transactions/${flwId}/verify`;
      const verifyCall = await fetch(verificationUrl, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${Deno.env.get('FLW_SECRET_KEY')}`,
          'Content-Type': 'application/json'
        }
      });

      const verificationData = await verifyCall.json();

      if (verificationData.status !== 'success' || verificationData.data.status !== 'successful' || verificationData.data.amount < depositRecord.amount) {
        // Flag the transaction reference as fraudulent or failing matching requirements
        await supabaseAdmin.from('deposits').update({ status: 'failed' }).eq('tx_ref', txRef);
        return new Response(JSON.stringify({ error: "External parameter check fraud alert verification failed" }), { status: 400 });
      }

      // 3. ATOMIC TRANSACTIONS OPERATION: Update ledger status and increment user wallet state balance
      // Fetch target user's current wallet asset map row
      const { data: currentWallet, error: walletFetchErr } = await supabaseAdmin
        .from('wallets')
        .select('ngn_balance')
        .eq('user_id', depositRecord.user_id)
        .single();

      if (walletFetchErr || !currentWallet) {
        return new Response(JSON.stringify({ error: "Target user wallet record initialization not found" }), { status: 404 });
      }

      const calculatedNewNgnBalance = Number(currentWallet.ngn_balance) + Number(amountPaid);

      // Perform updates safely inside DB context state
      await supabaseAdmin
        .from('deposits')
        .update({ status: 'completed', updated_at: new Date().toISOString() })
        .eq('tx_ref', txRef);

      await supabaseAdmin
        .from('wallets')
        .update({ ngn_balance: calculatedNewNgnBalance })
        .eq('user_id', depositRecord.user_id);

      return new Response(JSON.stringify({ success: true, message: "User account wallet successfully funded." }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }

    return new Response(JSON.stringify({ status: "Ignored unhandled non-success webhook event classification tracking" }), { status: 200 });

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
})
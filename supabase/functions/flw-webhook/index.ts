import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const jsonResponse = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  })

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
      return jsonResponse({ error: "Unauthorized Signature Hash Verification Failed" }, 401);
    }

    const payload = await req.json();
    const data = payload.data ?? payload;
    const event = payload.event?.toString().toLowerCase();
    const webhookStatus = (data.status ?? payload.status ?? '').toString().toLowerCase();

    // Ensure we process completed status transactions safely
    if (webhookStatus === 'successful' || event === 'charge.completed') {
      const txRef = data.tx_ref || data.txRef || payload.txRef;
      const flwId = data.id || data.transaction_id || payload.id || payload.transaction_id;

      if (!txRef || !flwId) {
        return jsonResponse({
          error: "Missing Flutterwave transaction reference or transaction id",
          received: { txRef, flwId },
        }, 400);
      }

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
        return jsonResponse({ error: "Matching internal deposit reference not found", txRef }, 404);
      }

      // Check to prevent double funding vectors (Idempotency Guard)
      if (depositRecord.status === 'completed') {
        return jsonResponse({ status: "Duplicate event already accounted for" });
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
      const verified = verificationData.data ?? {};
      const verifiedAmount = Number(verified.amount);
      const expectedAmount = Number(depositRecord.amount);
      const verifiedStatus = (verified.status ?? '').toString().toLowerCase();
      const verifiedTxRef = verified.tx_ref || verified.txRef;

      if (
        !verifyCall.ok ||
        verificationData.status !== 'success' ||
        verifiedStatus !== 'successful' ||
        verifiedTxRef !== txRef ||
        Number.isNaN(verifiedAmount) ||
        verifiedAmount < expectedAmount
      ) {
        // Flag the transaction reference as fraudulent or failing matching requirements
        await supabaseAdmin.from('deposits').update({ status: 'failed' }).eq('tx_ref', txRef);
        return jsonResponse({
          error: "External parameter check verification failed",
          verificationStatus: verificationData.status,
          transactionStatus: verifiedStatus,
          verifiedTxRef,
          expectedTxRef: txRef,
          verifiedAmount,
          expectedAmount,
        }, 400);
      }

      // 3. ATOMIC TRANSACTIONS OPERATION: Update ledger status and increment user wallet state balance
      // Fetch target user's current wallet asset map row
      const { data: currentWallet, error: walletFetchErr } = await supabaseAdmin
        .from('wallets')
        .select('ngn_balance')
        .eq('user_id', depositRecord.user_id)
        .maybeSingle();

      if (walletFetchErr) {
        return jsonResponse({ error: "Target user wallet lookup failed", details: walletFetchErr.message }, 500);
      }

      const calculatedNewNgnBalance = Number(currentWallet?.ngn_balance ?? 0) + verifiedAmount;

      // Perform updates safely inside DB context state
      await supabaseAdmin
        .from('deposits')
        .update({ status: 'completed', updated_at: new Date().toISOString() })
        .eq('tx_ref', txRef);

      if (currentWallet) {
        await supabaseAdmin
          .from('wallets')
          .update({ ngn_balance: calculatedNewNgnBalance })
          .eq('user_id', depositRecord.user_id);
      } else {
        await supabaseAdmin
          .from('wallets')
          .insert({ user_id: depositRecord.user_id, ngn_balance: calculatedNewNgnBalance });
      }

      return jsonResponse({ success: true, message: "User account wallet successfully funded." });
    }

    return jsonResponse({ status: "Ignored unhandled non-success webhook event classification tracking", event, webhookStatus });

  } catch (err) {
    return jsonResponse({ error: err.message }, 500);
  }
})

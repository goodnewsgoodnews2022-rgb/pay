import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const jsonResponse = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, verif-hash",
    },
  })

serve(async (req) => {
  // Catch Preflight request CORS triggers smoothly
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: { 
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, verif-hash',
      } 
    })
  }

  try {
    const payload = await req.json();

    // 🚀 ACTION 1: HANDLE FRONTEND INITIALIZATION REQUEST (FLUTTER WEB)
    if (payload.action === 'initialize_payment') {
      const flwSecretKey = Deno.env.get('FLW_SECRET_KEY');
      if (!flwSecretKey) {
        return jsonResponse({ error: "Server Error: Secret key missing from backend settings." }, 500);
      }

      // Hit Flutterwave API to create a production-safe Standard Checkout Session URL
      const flwResponse = await fetch('https://api.flutterwave.com/v3/payments', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${flwSecretKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          tx_ref: payload.tx_ref,
          amount: payload.amount,
          currency: payload.currency,
          redirect_url: payload.redirect_url,
          customer: {
            email: payload.email,
            name: payload.name,
          },
          customizations: {
            title: "Wallet Cash-In",
            description: "Fund your account pool via Flutterwave Checkout Gateway",
          }
        }),
      });

      const flwData = await flwResponse.json();

      if (!flwResponse.ok || flwData.status !== 'success') {
        return jsonResponse({ 
          error: "Flutterwave endpoint initialization failed", 
          details: flwData.message 
        }, 400);
      }

      // Return the secure link to your Flutter front-end asset
      return jsonResponse({ checkout_url: flwData.data.link }, 200);
    }

    // 🔒 ACTION 2: HANDLE INCOMING WEBHOOK EVENT (FLUTTERWAVE SERVERS)
    const flwSignature = req.headers.get('verif-hash');
    const systemSecretHash = Deno.env.get('FLW_WEBHOOK_HASH');

    if (!flwSignature || flwSignature !== systemSecretHash) {
      return jsonResponse({ error: "Unauthorized Signature Hash Verification Failed" }, 401);
    }

    const data = payload.data ?? payload;
    const event = payload.event?.toString().toLowerCase();
    const webhookStatus = (data.status ?? payload.status ?? '').toString().toLowerCase();

    if (webhookStatus === 'successful' || event === 'charge.completed') {
      const txRef = data.tx_ref || data.txRef || payload.txRef;
      const flwId = data.id || data.transaction_id || payload.id || payload.transaction_id;

      if (!txRef || !flwId) {
        return jsonResponse({
          error: "Missing Flutterwave transaction reference or transaction id",
          received: { txRef, flwId },
        }, 400);
      }

      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      );

      const { data: depositRecord, error: fetchErr } = await supabaseAdmin
        .from('deposits')
        .select('*')
        .eq('tx_ref', txRef)
        .single();

      if (fetchErr || !depositRecord) {
        return jsonResponse({ error: "Matching internal deposit reference not found", txRef }, 404);
      }

      if (depositRecord.status === 'completed') {
        return jsonResponse({ status: "Duplicate event already accounted for" });
      }

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
        await supabaseAdmin.from('deposits').update({ status: 'failed' }).eq('tx_ref', txRef);
        return jsonResponse({
          error: "External parameter check verification failed",
          verificationStatus: verificationData.status,
          transactionStatus: verifiedStatus,
        }, 400);
      }

      // 🏦 1. READ FROM THE CORRECT TABLE: 'fiat_wallets'
      const { data: currentWallet, error: walletFetchErr } = await supabaseAdmin
        .from('fiat_wallets')
        .select('ngn_balance')
        .eq('user_id', depositRecord.user_id)
        .maybeSingle();

      if (walletFetchErr) {
        return jsonResponse({ error: "Target user wallet lookup failed", details: walletFetchErr.message }, 500);
      }

      const calculatedNewNgnBalance = Number(currentWallet?.ngn_balance ?? 0) + verifiedAmount;
      const timestampIso = new Date().toISOString();

      // 2. UPDATE DEPOSIT STATUS LOG ENTRY
      await supabaseAdmin
        .from('deposits')
        .update({ status: 'completed', updated_at: timestampIso })
        .eq('tx_ref', txRef);

      // 🔄 3. SYNC TO THE CORRECT POOL TABLE: 'fiat_wallets'
      if (currentWallet) {
        await supabaseAdmin
          .from('fiat_wallets')
          .update({ 
            ngn_balance: calculatedNewNgnBalance,
            last_synced_at: timestampIso 
          })
          .eq('user_id', depositRecord.user_id);
      } else {
        await supabaseAdmin
          .from('fiat_wallets')
          .insert({ 
            user_id: depositRecord.user_id, 
            ngn_balance: calculatedNewNgnBalance,
            last_synced_at: timestampIso
          });
      }

      // 👥 4. MIRROR SYNCHRONIZATION WITH THE 'profiles' TABLE
      await supabaseAdmin
        .from('profiles')
        .update({ naira_balance: calculatedNewNgnBalance })
        .eq('id', depositRecord.user_id);

      // 📝 5. WRITE SYSTEM TRANSACTION EVENT AUDIT LOG ENTRY
      await supabaseAdmin
        .from('balance_audit_logs')
        .insert({
          user_id: depositRecord.user_id,
          ngn_balance: calculatedNewNgnBalance,
          synced_at: timestampIso,
          source: 'flutterwave_webhook_sync',
        });

      return jsonResponse({ success: true, message: "User account holding pool successfully funded." });
    }

    return jsonResponse({ status: "Ignored unhandled non-success webhook event classification tracking", event, webhookStatus });

  } catch (err) {
    return jsonResponse({ error: err.message }, 500);
  }
})
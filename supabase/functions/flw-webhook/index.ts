import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, verif-hash",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  try {
    const payload = await req.json();

    // -------------------------
    // 1) INITIALIZE PAYMENT
    // -------------------------
    if (payload?.action === "initialize_payment") {
      const flwSecret = Deno.env.get("FLW_SECRET_KEY");
      const redirectUrl = payload?.redirect_url ?? Deno.env.get("FLW_REDIRECT_URL");

      if (!flwSecret) {
        return new Response(JSON.stringify({ error: "FLW_SECRET_KEY missing" }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      if (!redirectUrl) {
        return new Response(JSON.stringify({ error: "redirect_url missing" }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const txRef = payload.tx_ref;
      const amount = payload.amount;
      const currency = payload.currency ?? "NGN";

      if (!txRef || !amount) {
        return new Response(JSON.stringify({ error: "tx_ref and amount are required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const customer = payload.customer ?? {};
      const meta = payload.meta ?? {};

      const response = await fetch("https://api.flutterwave.com/v3/payments", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${flwSecret}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          tx_ref: txRef,
          amount: amount,
          currency: currency,
          redirect_url: redirectUrl,
          customer: {
            email: customer.email,
            name: customer.name,
          },
          meta: meta,
          customizations: payload.customizations ?? { title: "Wallet Funding" },
        }),
      });

      const result = await response.json();

      return new Response(JSON.stringify(result), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // -------------------------
    // 2) WEBHOOK VERIFICATION
    // -------------------------
    const signatureHeader = req.headers.get("verif-hash") ?? "";
    const expectedSignature = Deno.env.get("FLW_WEBHOOK_HASH") ?? "";

    if (!expectedSignature || signatureHeader !== expectedSignature) {
      return new Response("Unauthorized", { status: 401 });
    }

    const event = payload?.event;
    // Flutterwave event names can vary; accept common ones
    const allowedEvents = new Set([
      "charge.completed",
      "charge.success",
      "charge.successful",
      "payment.charge.completed",
    ]);

    // If event is missing or not in allowed list: ignore safely
    if (!event || !allowedEvents.has(event)) {
      console.log("Ignoring event:", event);
      return new Response("Ignored event", { status: 200 });
    }

    const flwId = payload?.data?.id;
    const txRefFromPayload =
      payload?.data?.tx_ref ??
      payload?.data?.txRef ??
      payload?.data?.transaction_id; // fallback (optional)

    if (!flwId) {
      return new Response(JSON.stringify({ error: "Missing flutterwave transaction id (data.id)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Verify transaction with Flutterwave
    const verify = await fetch(`https://api.flutterwave.com/v3/transactions/${flwId}/verify`, {
      headers: { Authorization: `Bearer ${Deno.env.get("FLW_SECRET_KEY")}` },
    });

    const verifyData = await verify.json();
    if (verifyData?.status !== "success") {
      return new Response(JSON.stringify({ error: "Verification Failed" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!txRefFromPayload) {
      return new Response(JSON.stringify({ error: "Missing tx_ref in webhook payload" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const txRef = String(txRefFromPayload).trim();

    // A) Fetch transaction row to get user_identifier
    const { data: transactionRecord, error: fetchError } = await supabase
      .from("transactions")
      .select("user_identifier, id, status")
      .eq("id", txRef)
      .maybeSingle();

    if (fetchError) {
      throw new Error(`DB fetch error: ${fetchError.message}`);
    }
    if (!transactionRecord) {
      // If you ever see this, your tx_ref stored differs from what Flutterwave sends.
      console.log("Transaction not found for tx_ref:", txRef);
      return new Response(JSON.stringify({ error: "Transaction record not found in database" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // B) Update transaction status
    const amountFromWebhook = payload?.data?.amount ?? verifyData?.data?.amount;
    const amountNumber = Number(amountFromWebhook);

    const { data: updatedRows, error: transactionError } = await supabase
      .from("transactions")
      .update({
        status: "success",
      })
      .eq("id", txRef)
      .select();

    if (transactionError) throw transactionError;

    // C) Increment balance (only if update actually matched something)
    if (!updatedRows || updatedRows.length === 0) {
      console.log("Update matched 0 rows for tx_ref:", txRef);
      return new Response(JSON.stringify({ error: "No transaction rows updated" }), {
        status: 409,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (!Number.isFinite(amountNumber) || amountNumber <= 0) {
      console.log("Invalid amount from webhook:", amountFromWebhook);
      // You can choose to fail or still mark successful; here we fail to avoid bad ledger.
      return new Response(JSON.stringify({ error: "Invalid amount from webhook" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { error: rpcError } = await supabase.rpc("update_wallet_balance", {
      user_id: transactionRecord.user_identifier,
      amount_to_add: amountNumber,
    });

    if (rpcError) throw rpcError;

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("Critical Error:", e?.message ?? e);
    return new Response(JSON.stringify({ error: e?.message ?? String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
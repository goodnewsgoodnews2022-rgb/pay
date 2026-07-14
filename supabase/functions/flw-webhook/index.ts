import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

await supabaseClient.rpc('increment_balance', { 
  p_user_id: userId, 
  p_amount: amount 
});

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, verif-hash",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();

    //=========================================================
    // INITIALIZE PAYMENT
    //=========================================================

    if (payload.action === "initialize_payment") {
      const flutterwave = await fetch(
        "https://api.flutterwave.com/v3/payments",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${Deno.env.get("FLW_SECRET_KEY")}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            tx_ref: payload.tx_ref,
            amount: payload.amount,
            currency: "NGN",
            redirect_url: payload.redirect_url,
            customer: {
              email: payload.email,
              name: payload.name,
            },
            customizations: {
              title: "Wallet Funding",
            },
          }),
        },
      );

      const result = await flutterwave.json();

      return new Response(JSON.stringify(result), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      });
    }

    //=========================================================
    // VERIFY WEBHOOK
    //=========================================================

    const signature = req.headers.get("verif-hash");

    if (signature !== Deno.env.get("FLW_WEBHOOK_HASH")) {
      return new Response("Unauthorized", {
        status: 401,
      });
    }

    const event = payload.event;

    if (event !== "charge.completed") {
      return new Response("Ignored");
    }

    const txRef = payload.data.tx_ref;
    const flwId = payload.data.id;

    //---------------------------------------------------------
    // VERIFY TRANSACTION
    //---------------------------------------------------------

    const verify = await fetch(
      `https://api.flutterwave.com/v3/transactions/${flwId}/verify`,
      {
        headers: {
          Authorization: `Bearer ${Deno.env.get("FLW_SECRET_KEY")}`,
        },
      },
    );

    const verifyData = await verify.json();

    if (
      verifyData.status !== "success" ||
      verifyData.data.status !== "successful"
    ) {
      return new Response("Verification failed");
    }

    //---------------------------------------------------------
    // CONNECT SUPABASE
    //---------------------------------------------------------

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    //---------------------------------------------------------
    // FIND DEPOSIT
    //---------------------------------------------------------

    const { data: deposit } = await supabase
      .from("deposits")
      .select("*")
      .eq("tx_ref", txRef)
      .single();

    if (!deposit) {
      return new Response("Deposit not found", {
        status: 404,
      });
    }

    //---------------------------------------------------------
    // ALREADY COMPLETED
    //---------------------------------------------------------

    if (deposit.status === "completed") {
      return new Response("Already completed");
    }

    //---------------------------------------------------------
    // UPDATE DEPOSIT
    //---------------------------------------------------------

    const { error: depositError } = await supabase
      .from("deposits")
      .update({
        status: "completed",
        flutterwave_tx_id: flwId,
        updated_at: new Date().toISOString(),
      })
      .eq("tx_ref", txRef);

    if (depositError) {
      throw depositError;
    }

    //---------------------------------------------------------
    // GET USER WALLET
    //---------------------------------------------------------

    const { data: wallet } = await supabase
      .from("fiat_wallets")
      .select("*")
      .eq("user_id", deposit.user_id)
      .maybeSingle();

    //---------------------------------------------------------
    // CREATE WALLET
    //---------------------------------------------------------

    if (!wallet) {
      const { error } = await supabase
        .from("fiat_wallets")
        .insert({
          user_id: deposit.user_id,
          currency: "NGN",
          ngn_balance: deposit.amount,
        });

      if (error) throw error;
    }

    //---------------------------------------------------------
    // UPDATE WALLET
    //---------------------------------------------------------

    else {
      const { error } = await supabase
        .from("fiat_wallets")
        .update({
          ngn_balance:
            Number(wallet.ngn_balance) + Number(deposit.amount),
        })
        .eq("user_id", deposit.user_id);

      if (error) throw error;
    }

    return new Response(
      JSON.stringify({
        success: true,
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({
        error: e.message,
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
});
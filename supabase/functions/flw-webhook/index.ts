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

    // =========================================================
    // 1. INITIALIZE PAYMENT
    // =========================================================
   // =========================================================
// 1. INITIALIZE PAYMENT (Updated with Debugging)
// =========================================================
if (payload.action === "initialize_payment") {
  const flwSecret = Deno.env.get("FLW_SECRET_KEY");
  
  // DEBUG: Verify key exists
  if (!flwSecret) {
    console.error("CRITICAL: FLW_SECRET_KEY is missing in Deno.env!");
  }

  const response = await fetch("https://api.flutterwave.com/v3/payments", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${flwSecret}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      tx_ref: payload.tx_ref,
      amount: payload.amount,
      currency: "NGN",
      redirect_url: payload.redirect_url,
      customer: { email: payload.email, name: payload.name },
      meta: { user_id: payload.user_id },
      customizations: { title: "Wallet Funding" },
    }),
  });

  const result = await response.json();
  
  // DEBUG: Log everything coming back from Flutterwave
  console.log("FLUTTERWAVE RESPONSE:", JSON.stringify(result));

  if (result.status !== "success") {
     console.error("FLUTTERWAVE FAILED:", result.message);
  }

  return new Response(JSON.stringify(result), { 
    headers: { ...corsHeaders, "Content-Type": "application/json" } 
  });
}
    // =========================================================
    // 2. WEBHOOK VERIFICATION
    // =========================================================
    const signature = req.headers.get("verif-hash");
    if (signature !== Deno.env.get("FLW_WEBHOOK_HASH")) {
      return new Response("Unauthorized", { status: 401 });
    }

    if (payload.event !== "charge.completed") {
      return new Response("Ignored event", { status: 200 });
    }

    const txRef = payload.data.tx_ref;
    const flwId = payload.data.id;

    const verify = await fetch(`https://api.flutterwave.com/v3/transactions/${flwId}/verify`, {
      headers: { Authorization: `Bearer ${Deno.env.get("FLW_SECRET_KEY")}` },
    });
    const verifyData = await verify.json();

    if (verifyData.status !== "success") {
      return new Response(JSON.stringify({ error: "Verification Failed" }), { status: 400 });
    }

    // A. Fetch the user_id from the deposits table using the tx_ref
    const { data: depositRecord, error: fetchError } = await supabase
      .from('deposits')
      .select('user_id')
      .eq('tx_ref', txRef)
      .single();

    if (fetchError || !depositRecord) {
      throw new Error("Transaction record not found in database");
    }

    // B. Update Deposit Status
    const { error: depositError } = await supabase
      .from('deposits')
      .update({ status: 'successful' })
      .eq('tx_ref', txRef);

    if (depositError) throw depositError;

    // C. Increment Balance using the fetched user_id
    const { error: rpcError } = await supabase.rpc('increment_balance', { 
      p_user_id: depositRecord.user_id, 
      p_amount: payload.data.amount 
    });

    if (rpcError) throw rpcError;

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (e) {
    console.error("Critical Error:", e.message);
    return new Response(JSON.stringify({ error: e.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
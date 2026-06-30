import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // Allows your Flutter Web application to bypass CORS blocks
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight options checks sent by the browser
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { action, payload } = await req.json();
    const apiKey = Deno.env.get("NOWPAYMENTS_API_KEY"); // Safely pulled from cloud secrets!

    if (!apiKey) {
      throw new Error("NOWPayments API Key is not configured in your Supabase Edge secrets.");
    }

    let url = "https://api.nowpayments.io/v1/payment";
    
    // Dynamically direct routes based on the incoming action parameters
    if (action === "create_payout") {
      url = "https://api.nowpayments.io/v1/payout";
    } else if (action === "get_rate") {
      url = `https://api.nowpayments.io/v1/estimate?amount=${payload.amount}&currency_from=${payload.from}&currency_to=${payload.to}`;
    }

    const fetchConfig: RequestInit = {
      method: action === "get_rate" ? "GET" : "POST",
      headers: {
        "x-api-key": apiKey,
        "Content-Type": "application/json",
      },
    };

    if (action !== "get_rate" && payload) {
      fetchConfig.body = JSON.stringify(payload);
    }

    const response = await fetch(url, fetchConfig);
    const data = await response.json();

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: response.status,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: corsHeaders,
      status: 500,
    });
  }
})
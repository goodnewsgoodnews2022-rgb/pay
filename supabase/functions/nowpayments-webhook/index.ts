import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 })
  }

  try {
    const incomingSignature = req.headers.get('x-nowpayments-sig')
    if (!incomingSignature) {
      return new Response('Missing Signature Fingerprint', { status: 401 })
    }

    const rawBody = await req.text()
    const body = JSON.parse(rawBody)

    // 1. Sort incoming fields alphabetically for strict compliance validation rules
    const sortedKeys = Object.keys(body).sort()
    const signedFields: Record<string, any> = {}
    for (const key of sortedKeys) {
      signedFields[key] = body[key]
    }
    const serializePayload = JSON.stringify(signedFields)

    // 2. Fetch secure project variable keys out of your cloud environment vault
    const ipnSecret = Deno.env.get('NOWPAYMENTS_IPN_SECRET') || ''

    // 3. Compute local HMAC-SHA512 verification signature hash string
    const encoder = new TextEncoder()
    const keyData = encoder.encode(ipnSecret)
    const messageData = encoder.encode(serializePayload)

    const cryptoKey = await crypto.subtle.importKey(
      "raw",
      keyData,
      { name: "HMAC", hash: "SHA-512" },
      false,
      ["sign"]
    )
    
    const signatureBuffer = await crypto.subtle.sign("HMAC", cryptoKey, messageData)
    const calculatedSignature = Array.from(new Uint8Array(signatureBuffer))
      .map(b => b.toString(16).padStart(2, "0"))
      .join("")

    // 4. Security Check: Terminate unauthorized or fraudulent callback pings instantly
    if (incomingSignature !== calculatedSignature) {
      return new Response('Authentication token fingerprint verification failed', { status: 401 })
    }

    // 5. Establish secure database client using project service role privileges
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 6. Update the transaction row status cleanly in your relational table ledger
    const { error } = await supabaseClient
      .from('crypto_deposits')
      .upsert({
        payment_id: body.payment_id.toString(),
        status: body.payment_status,
        price_amount: parseFloat(body.price_amount),
        updated_at: new Date().toISOString()
      }, { onConflict: 'payment_id' })

    if (error) throw error

    return new Response('OK Status Signal Logged', { status: 200 })

  } catch (err) {
    console.error('Error handling transaction state metrics:', err)
    return new Response('Internal Server Processing Interruption', { status: 500 })
  }
})
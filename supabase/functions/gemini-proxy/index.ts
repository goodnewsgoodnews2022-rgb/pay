// supabase/functions/gemini-proxy/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// ✅ Use Groq instead of Gemini
const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY")!;

const SYSTEM_INSTRUCTION = `
You are a helpful and empathetic support chatbot for the "Pay Fintech" app.
You ONLY answer questions related to the app's features, such as deposits, withdrawals, transfers, and KYC verification.
You do not provide financial advice.
If a user asks about a topic outside these areas, politely redirect them to our official support channels.
`;

serve(async (req) => {
  try {
    const { message, context } = await req.json();

    const prompt = `
    ${SYSTEM_INSTRUCTION}

    ${context ? `Relevant information from our knowledge base: ${context}` : ''}

    User: ${message}
    Assistant:`;

    // Call Groq API
    const response = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${GROQ_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "llama-3.3-70b-versatile", // or "mixtral-8x7b-32768"
          messages: [
            { role: "system", content: SYSTEM_INSTRUCTION },
            { role: "user", content: message }
          ],
          temperature: 0.7,
          max_tokens: 500,
        }),
      }
    );

    const data = await response.json();
    const aiResponse = data.choices?.[0]?.message?.content || "Sorry, I couldn't process that.";

    return new Response(JSON.stringify({ reply: aiResponse }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error.message);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    );
  }
});
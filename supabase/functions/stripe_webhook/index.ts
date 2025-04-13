// functions/stripe_webhook/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders } from '../_shared/cors.ts';
import { createClient } from "jsr:@supabase/supabase-js";

const supabase_url = Deno.env.get('SUPABASE_URL');
const service_role_key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const brevo_api_key = Deno.env.get('BREVO_API_KEY');

if (!supabase_url || !service_role_key || !brevo_api_key) {
  throw new Error('Missing SUPABASE_URL, SERVICE_ROLE_KEY or BREVO_API_KEY');
}

const supabase = createClient(supabase_url, service_role_key, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  const event = await req.json();
  console.log("Stripe event received:", event.type);

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const checkoutSessionId = session.id;

    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*')
      .eq('checkout_session_id', checkoutSessionId)
      .single();

    if (orderError || !order) {
      console.error("Order not found", orderError);
      return new Response(JSON.stringify({ error: 'Order not found' }), {
        status: 404,
        headers: corsHeaders
      });
    }

    const { data: user, error: userError } = await supabase
      .from('users')
      .select('email')
      .eq('id', order.user_id)
      .single();

    if (userError || !user?.email) {
      console.error("User not found", userError);
      return new Response(JSON.stringify({ error: 'User not found' }), {
        status: 404,
        headers: corsHeaders
      });
    }

    const { error: updateError } = await supabase
      .from('orders')
      .update({ state: 'paid' })
      .eq('id', order.id);

    if (updateError) {
      console.error("Failed to update order", updateError);
      return new Response(JSON.stringify({ error: 'Update failed' }), {
        status: 500,
        headers: corsHeaders
      });
    }

    const token = crypto.randomUUID();

    const { error: tokenError } = await supabase
      .from('users')
      .update({ pro_signup_token: token })
      .eq('id', order.user_id);

    if (tokenError) {
      console.error("Failed to store pro_signup_token", tokenError);
      return new Response(JSON.stringify({ error: 'Token update failed' }), {
        status: 500,
        headers: corsHeaders
      });
    }

    const signupLink = `https://www.myboop.fr/professionals/new?token=${token}`;

    const emailResponse = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        accept: "application/json",
        "api-key": brevo_api_key,
        "content-type": "application/json"
      },
      body: JSON.stringify({
        sender: { name: "Boop", email: "hello@boopfr.com" },
        to: [{ email: user.email }],
        subject: "Bienvenue sur Boop - Crée ton profil professionnel 🐶",
        htmlContent: `
          <h2 style="font-family: Arial, sans-serif; color: #e68e2e;">
            👋 Bienvenue sur Boop, <br>le réseau des pros du monde animal 🐾
          </h2>
          <p style="font-family: Arial, sans-serif; color: #333; font-size: 16px;">
            Merci pour ton inscription 🙌<br>
            Tu es à deux clics de connecter ton expertise à des centaines de clients qui te cherchent déjà.
          </p>
          <p style="font-family: Arial, sans-serif; color: #333; font-size: 16px;">
            Pour activer ton espace professionnel, c’est par ici :
          </p>
          <a href="${signupLink}"
            style="display: inline-block; padding: 14px 24px; background-color: #e68e2e; color: white; text-decoration: none; border-radius: 8px; font-weight: bold; font-size: 16px;">
            🚀 Créer mon compte pro
          </a>
          <p style="font-family: Arial, sans-serif; color: #777; font-size: 14px; margin-top: 30px;">
            À très vite sur Boop ❤️<br>
            L’équipe Boop
          </p>
        `
      })
    });

    const redirect_url = signupLink;

    return new Response(JSON.stringify({
      message: 'Order updated to paid and email sent.',
      redirect_url,
      user_id: order.user_id
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  return new Response(JSON.stringify({
    message: 'Unhandled event type'
  }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
});

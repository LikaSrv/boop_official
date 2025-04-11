// functions/stripe_webhook/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders } from '../_shared/cors.ts';
import { createClient } from "jsr:@supabase/supabase-js";

// Récupération des variables d'environnement
const supabase_url = Deno.env.get('SUPABASE_URL');
const service_role_key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

if (!supabase_url || !service_role_key) {
  throw new Error('Environment variables missing: SUPABASE_URL, SERVICE_ROLE_KEY');
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

    const redirect_url = `http://localhost:3000/professionals/new`;

    return new Response(JSON.stringify({
      message: 'Order updated to paid.',
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

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { corsHeaders } from '../_shared/cors.ts'
import { createClient } from "jsr:@supabase/supabase-js"

// Configurer Supabase avec les informations nécessaires
const supabase_url = Deno.env.get('SUPABASE_URL')
const service_role_key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

if (!supabase_url || !service_role_key) {
  throw new Error('Environment variables missing: SUPABASE_URL, SERVICE_ROLE_KEY')
}

const supabase = createClient(supabase_url, service_role_key, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  if (req.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Method not allowed' }),
      { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const event = await req.json();

  if (event.type === 'checkout.session.completed') {
    const email = event.data.object.customer_details.email

    if (!email) {
      return new Response(
        JSON.stringify({ error: 'No email found in session' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { data, error } = await supabase.auth.admin.inviteUserByEmail(email, {
      redirectTo: "https://430521f0-e270-4dc5-9daf-cd1ab3832471.weweb-preview.io/en/create-password/"
    })

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ message: 'User invited successfully', user: data }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  return new Response(
    JSON.stringify({ message: 'Event received but not handled' }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  )
})

// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'npm:@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts' // Import shared CORS headers

console.log(`Function "training-webhook-handler" up and running!`)

// IMPORTANT: This function needs SERVICE_ROLE_KEY to update any user's profile
// Set SUPABASE_SERVICE_ROLE_KEY in Supabase Secrets!
const supabaseAdminClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Use Service Role Key
)

serve(async (req: Request) => {
  // 1. Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Optional: Add security check (e.g., verify a secret header from Fal if available)
  // const falSecret = req.headers.get('x-fal-secret')
  // if (falSecret !== Deno.env.get('FAL_WEBHOOK_SECRET')) {
  //    console.error('Invalid webhook secret')
  //    return new Response('Unauthorized', { status: 401 })
  // }

  try {
    // 2. Parse the incoming request body from Fal AI
    const body = await req.json()
    console.log('Webhook received body:', JSON.stringify(body, null, 2))

    // 3. Extract User ID from URL Query Parameter
    const url = new URL(req.url)
    const userId = url.searchParams.get('user_id')
    if (!userId) {
        console.error('Webhook error: Missing user_id in request URL query parameters')
        return new Response('Missing user_id in URL', { status: 400 })
    }
    console.log(`Processing webhook for user ID: ${userId}`)

    // 4. Extract necessary data from Fal payload
    // Check both formats: our test format with top-level 'status' and Fal's actual format with payload.success
    const status = body.status
    const isSuccess = body.payload?.success === true
    const falModelId = body.payload?.diffusers_lora_file?.url

    // 5. Check if training was successful and model ID exists
    if ((status === 'COMPLETED' || isSuccess) && falModelId) {
      console.log(`Training completed for user ${userId}. Model ID: ${falModelId}`)
      
      // 6. Update the user's profile in Supabase
      const { data, error: updateError } = await supabaseAdminClient
        .from('profiles')
        .update({ fal_lora_model_id: falModelId })
        .eq('id', userId)
        .select()
        .single()

      if (updateError) {
        console.error(`Error updating profile for user ${userId}:`, updateError)
        return new Response('Error updating profile', { status: 500 })
      }

      console.log(`Successfully updated profile for user ${userId}:`, data)
      return new Response('Webhook processed successfully', { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      })

    } else {
      // Handle failed training or missing model ID
      console.warn(`Training status not COMPLETED or model ID missing for user ${userId}. Status: ${status}. ModelID: ${falModelId}`)
      return new Response('Webhook acknowledged, training not completed or model ID missing', { 
         headers: { ...corsHeaders, 'Content-Type': 'application/json' },
         status: 200 
      })
    }

  } catch (error) {
    console.error('Error processing webhook:', error)
    return new Response(JSON.stringify({ error: error.message || 'Internal Server Error' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/training-webhook-handler' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

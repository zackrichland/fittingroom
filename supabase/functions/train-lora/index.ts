// TOP LEVEL SCRIPT STARTING
console.log("--- train-lora module loading ---");

// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'npm:@supabase/supabase-js@2'
import { fal } from 'npm:@fal-ai/client'
import { corsHeaders } from '../_shared/cors.ts' // Assuming you have CORS headers defined
import JSZip from 'npm:jszip@3.10.1'

console.log(`Function "train-lora" v2 up and running!`)

// Add log to check if FAL_API_KEY is loaded
console.log("FAL_API_KEY present?", !!Deno.env.get("FAL_API_KEY"));

serve(async (req: Request) => {
  console.log(`--- Request received: ${req.method} ${req.url} ---`);

  // --- Check the essential secret ---
  const falApiKey = Deno.env.get("FAL_API_KEY");
  // console.log("Handler sees FAL_API_KEY?", !!falApiKey); // Keep commented unless needed
  if (!falApiKey) {
    console.error("CRITICAL: FAL_API_KEY environment variable not found!");
    return new Response(JSON.stringify({ error: 'Server configuration error: Missing API Key' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
  // --- End Secret Check ---

  // Configure Fal client
  fal.config({
    credentials: falApiKey,
  });

  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Create Supabase client with Auth context
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      // Create client with auth header to ensure user is authenticated
      // Authorization: Bearer <JWT> is expected in the request
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // 2. Get authenticated user
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) {
      console.error('User fetch error:', userError?.message)
      return new Response(JSON.stringify({ error: 'User not authenticated' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 401,
      })
    }
    const userId = user.id
    console.log(`Training request received for user: ${userId}`)

    // 3. Parse incoming image URLs
    const { imageUrls } = await req.json(); 
    if (!imageUrls || !Array.isArray(imageUrls) || imageUrls.length === 0) {
      return new Response(JSON.stringify({ error: 'Missing or invalid image URLs' }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 });
    }
    console.log(`Received ${imageUrls.length} signed image URLs.`);

    // 4. Download images and Create ZIP archive
    const zip = new JSZip();
    console.log('Downloading images and adding to ZIP...');
    let imageCounter = 0;
    for (const imageUrl of imageUrls) {
        console.log(`Fetching image from signed URL...`); // Don't log the full signed URL
        const response = await fetch(imageUrl);
        if (!response.ok) {
            throw new Error(`Failed to fetch image: ${response.status} ${response.statusText}`);
        }
        const imageData = await response.arrayBuffer();
        
        // Basic extension guessing (can be improved)
        const urlParts = new URL(imageUrl).pathname.split('.');
        const fileExtension = urlParts.length > 1 ? urlParts.pop() ?? 'jpg' : 'jpg';
        
        imageCounter++;
        const fileName = `image_${imageCounter}.${fileExtension}`;
        zip.file(fileName, imageData);
        console.log(`Added ${fileName} to ZIP.`);
    }
    console.log('Generating final ZIP archive...');
    const zipBlob = await zip.generateAsync({ type: 'blob', compression: "DEFLATE", compressionOptions: { level: 6 } }); // Level 6 for balance
    console.log('ZIP archive generated successfully.');

    // 5. Upload ZIP to Fal storage
    console.log('Uploading ZIP to Fal storage...');
    const falFile = new File([zipBlob], `${userId}_training_images.zip`, { type: 'application/zip' });
    const zipUrl = await fal.storage.upload(falFile); // Get the single URL for the zip
    console.log(`ZIP uploaded successfully to Fal: ${zipUrl}`);

    // 6. Construct Webhook URL (with user ID)
    const projectRef = Deno.env.get('SUPABASE_URL')?.split('.')[0]?.split('//')[1];
    if (!projectRef) { throw new Error("SUPABASE_URL missing"); }
    // Append userId as a query parameter
    const webhookUrl = `https://${projectRef}.supabase.co/functions/v1/training-webhook-handler?user_id=${userId}`;
    console.log(`Using webhook URL: ${webhookUrl}`);

    // 7. Initiate training via Fal AI - Send the ZIP URL string
    const triggerWord = `zwx_${userId}`; // Unique trigger word per user
    console.log(`Submitting training job to Fal with trigger word: ${triggerWord}`);

    const falPayload = {
      input: {
        images_data_url: zipUrl, // Send the single zip URL as a string
        trigger_word: triggerWord, 
        // Add other potential fields if needed based on Fal docs, like is_style: false
        is_style: false, 
      },
      logs: true, 
      webhookUrl: webhookUrl, 
    }
    console.log("Fal subscribe payload:", JSON.stringify(falPayload)); // Log the payload being sent

    const result = await fal.subscribe('fal-ai/flux-lora-fast-training', falPayload);

    console.log(`Training job submitted. Fal Request ID: ${result.request_id}`);

    // 8. Return response to the client
    const responsePayload = {
      message: 'Training initiated successfully.',
      requestId: result.request_id, // Send request ID back to client
    }

    return new Response(JSON.stringify(responsePayload), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    console.error('Error processing training request:', error)
    return new Response(JSON.stringify({ error: error.message || 'Internal Server Error' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})

/* Example of how the iOS app would send the request:
   (Assuming 'imageDataArray' contains Data objects for each image)

   let base64Images = imageDataArray.map { $0.base64EncodedString(options: .lineLength64Characters) }
   // IMPORTANT: Need to add correct data URI prefix if not already present
   let prefixedBase64Images = base64Images.map { "data:image/jpeg;base64," + $0 } // Assuming JPEG

   let body: [String: Any] = ["imagesBase64": prefixedBase64Images]
   let bodyData = try JSONSerialization.data(withJSONObject: body)

   // ... create URLRequest to '/train-lora' endpoint
   // ... set method to POST
   // ... set 'Content-Type' to 'application/json'
   // ... set 'Authorization: Bearer <Supabase JWT>' header
   // ... set httpBody = bodyData
   // ... perform URLSession data task
*/

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/train-lora' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

# FittingRoom App Blueprint

Repository: https://github.com/zackrichland/fittingroom

## Project Overview
FittingRoom.ai is an iOS application that provides a virtual fitting room experience, allowing users to upload selfies and wardrobe items to generate AI-powered outfit recommendations using Supabase for backend and Fal AI for model training/inference.

## Core User Flow
1.  **Auth:** User signs up/logs in via Supabase Auth.
2.  **Training Image Upload:**
    *   User selects >= 8 selfies.
    *   App uploads images to Supabase Storage.
    *   App calls `train-lora` Supabase Edge Function with signed URLs.
3.  **Model Training (Backend):**
    *   `train-lora` function downloads images, zips them, uploads zip to Fal Storage, calls `fal.subscribe` to start training.
    *   Fal AI trains the LoRA model asynchronously.
    *   Upon completion, Fal calls `training-webhook-handler` Supabase Edge Function.
    *   Webhook handler updates the user's profile in Supabase DB with the `fal_lora_model_id`.
4.  **Outfit Generation (Future):**
    *   User selects clothing items (from camera, library, or saved wardrobe).
    *   User provides a text prompt.
    *   App calls `generate-image` Supabase Edge Function.
    *   `generate-image` function fetches user's `fal_lora_model_id`, calls Fal AI generation endpoint (using the LoRA), returns image(s).
    *   App displays generated outfit.
5.  **Wardrobe Management (Future):**
    *   Add/manage clothing items in Supabase Storage/DB.

## File Structure
```
/FittingRoomApp.swift
/Screens/
  AuthScreen.swift
  TrainingScreen.swift // Handles selfie upload & training trigger
  // HomeScreen.swift (Likely becomes the image generation screen)
  // WardrobeScreen.swift 
  // AddItemScreen.swift 
  // GeneratedResultScreen.swift 
/Components/
  // ... UI components ...
  ImagePicker.swift
/Resources/
  Assets.xcassets
  Info.plist
/supabase/
  config.toml
  /functions/
    /_shared/
      cors.ts
    /train-lora/
      index.ts
      deno.json
      package.json 
    /training-webhook-handler/
      index.ts
      deno.json
    // /generate-image/ (Future)
  /migrations/
    // ... DB migrations ...
Blueprint.md
Workshop.txt
```

## Tech Stack
- **Frontend**: SwiftUI (iOS)
- **Language**: Swift
- **Backend**: Supabase (Auth, Database, Storage, Edge Functions)
- **AI Provider**: Fal AI (fal.ai)
- **Design**: Native iOS components

## Backend Details

### Supabase Setup
*   **Auth:** Email/Password enabled.
*   **Database:** `profiles` table (stores user ID, `fal_lora_model_id`, etc.).
*   **Storage:** `training-images` bucket (RLS enabled for user-specific uploads).
*   **Edge Functions:**
    *   `train-lora`: See workflow above. Uses `fal-ai/client` npm package, `jszip`.
    *   `training-webhook-handler`: Receives completion notification from Fal, updates `profiles` table.
*   **Secrets Management:**
    *   Secrets (e.g., `FAL_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`) MUST be stored via **Edge Function Secrets** (UI or `supabase secrets set`). Do NOT use the Vault.
    *   When setting secrets with special characters (like `:`) via CLI, wrap the value in **single quotes** (`'value'`).

### Fal AI Integration
*   **Training Model:** `fal-ai/flux-lora-fast-training`.
*   **Payload (`train-lora` -> Fal):** Requires `input: { images_data_url: "<zip_url>", ... }` where `images_data_url` is a string URL to a zip archive uploaded to Fal Storage.
*   **Authentication:** Uses Fal API Key (`id:secret` format) set as `FAL_API_KEY` Supabase secret.

## Frontend Details
*   **`TrainingScreen.swift`:** Handles image selection (PhotosUI), uploads images sequentially to Supabase Storage, gets signed URLs, calls `train-lora` function.
    *   Requires increased `request.timeoutInterval` (e.g., 180s) for the function call to accommodate backend processing time.
    *   Receives confirmation of *submission*, not completion. Final status relies on webhook/profile update.
*   **Supabase Integration:** Uses `supabase-swift` library for auth, storage uploads, function calls.
*   **Configuration:** `Info.plist` stores `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Current Status (Post-Training Fix)
*   User authentication flow is functional.
*   Training image upload and submission to `train-lora` function works.
*   `train-lora` function correctly processes images, authenticates with Fal, and submits the training job.
*   Training completes successfully on Fal AI side (verified via Fal dashboard).
*   `training-webhook-handler` is deployed (functionality needs explicit testing).
*   iOS app timeout issue addressed.

## Future Roadmap (Immediate Next Steps)
1.  **Test `training-webhook-handler`:** Explicitly verify that when Fal completes training, the webhook is called and correctly updates the user's `fal_lora_model_id` in the `profiles` table.
2.  **Build Image Generation Feature:**
    *   Create a new `generate-image` Supabase Edge Function.
        *   Input: Prompt (String), potentially other parameters.
        *   Logic: Get user ID from JWT -> Fetch user's `fal_lora_model_id` from `profiles` table -> Call appropriate Fal *image generation* endpoint (e.g., SDXL) passing the prompt and referencing the user's LoRA model (`loras: [{ path: fal_lora_model_id, ... }]`).
        *   Output: URL(s) of generated image(s).
    *   Create Frontend UI (e.g., modify `HomeScreen` or new screen):
        *   Text input for the prompt.
        *   Button to trigger generation (calls `generate-image` function).
        *   Display area for the resulting image(s).
        *   Loading state indicator.
3.  **Refine UI/UX:** Improve loading states, error handling, and user feedback throughout the app.

## Development Phases (Updated)
*   Phase 1: MVP - Auth & Training Submission (✓ Completed)
*   Phase 2: Core Functionality - Image Generation using Trained Model (Next)
*   Phase 3: Wardrobe Management & Enhanced Generation
*   Phase 4: Polish, Monetization, Social (Future)

## Technical Considerations
*   Error handling for Fal API calls (rate limits, model errors).
*   Scalability of Edge Functions.
*   Cost management for Fal AI usage.
*   UI responsiveness during image generation.
*   Securely managing user prompts and generated images. 
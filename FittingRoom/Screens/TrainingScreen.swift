import SwiftUI
import PhotosUI // Import PhotosUI for the picker
import Supabase // Make sure Supabase is imported

struct TrainingScreen: View {
    @EnvironmentObject private var authManager: AuthManager // Need this to get user/session

    // State for image selection
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    @State private var isLoadingImages = false
    @State private var imageSelectionError: String?

    // State for the training submission process
    @State private var isSubmittingTraining = false
    @State private var submissionMessage: String?
    @State private var submissionError: String?

    // Constants for image requirements
    private let minimumRequiredImages = 6
    private let maximumAllowedImages = 8

    var hasEnoughImages: Bool {
        selectedImageData.count >= minimumRequiredImages
    }

    var body: some View {
        ZStack {
            // Consistent dark background
            Color(hex: "1a1a1a").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Train Your Style")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 5)

                Text("Upload \(minimumRequiredImages)-\(maximumAllowedImages) high-resolution photos: 3 clear selfies (different angles/expressions) and 3 full-body shots.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                // Photos Picker Button
                PhotosPicker(
                    selection: $selectedItems, // Binding to selected items
                    maxSelectionCount: maximumAllowedImages, // Limit selection
                    matching: .images // Only allow images
                ) {
                    Label("Select Photos (\(selectedImageData.count)/\(maximumAllowedImages))", systemImage: "photo.on.rectangle.angled")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                // Update image data when selection changes
                .onChange(of: selectedItems) { newItems in
                    loadImages(from: newItems)
                }

                // Display Loading/Error State
                if isLoadingImages {
                    ProgressView("Loading images...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = imageSelectionError {
                    Text("Error loading images: \(error)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                // ScrollView for selected image thumbnails
                if !selectedImageData.isEmpty {
                    Text("Selected Images:")
                         .font(.subheadline)
                         .foregroundColor(.white)
                         .padding(.top, 5)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedImageData.indices, id: \.self) { index in
                                if let uiImage = UIImage(data: selectedImageData[index]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            // Optional: Add a way to remove images later
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: 90) // Fixed height for the scroll view
                }

                Spacer() // Push training button to bottom

                // Start Training Button
                Button(action: {
                    startTraining()
                }) {
                    HStack {
                        Spacer()
                         // Show progress view when submitting
                        if isSubmittingTraining {
                             ProgressView().tint(.white)
                         } else {
                            Text("Start Training")
                                .font(.headline)
                         }
                        Spacer()
                    }
                    .padding()
                    .background(hasEnoughImages && !isSubmittingTraining ? Color.green : Color.gray) // Also disable background when submitting
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!hasEnoughImages || isSubmittingTraining) // Disable if not enough images OR submitting
                .padding(.bottom, 10)
                
                // Display submission status messages
                if let message = submissionMessage {
                    Text(message)
                        .foregroundColor(.green)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                }
                if let error = submissionError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)
                }

            }
            .padding() // Padding for the main VStack content
        }
        .navigationTitle("Train Your Model")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    // Function to load image data from selected PhotosPickerItems AND RESIZE/COMPRESS
    private func loadImages(from items: [PhotosPickerItem]) {
        isLoadingImages = true
        imageSelectionError = nil
        selectedImageData = [] // Clear previous selections
        let maxDimension: CGFloat = 1024 // Max width/height for resizing
        let compressionQuality: CGFloat = 0.7 // JPEG compression quality (0.0 to 1.0)

        // Create a task group to load and process images concurrently
        Task {
            var processedData: [Data] = []
            var loadErrors: [String] = []
            
            do {
                try await withThrowingTaskGroup(of: Data?.self) { group in
                    for item in items {
                        group.addTask {
                            do {
                                // 1. Load original data
                                guard let originalData = try? await item.loadTransferable(type: Data.self) else {
                                    print("Failed to load data for one item.")
                                    return nil // Skip this item
                                }
                                
                                // 2. Create UIImage
                                guard let originalImage = UIImage(data: originalData) else {
                                    print("Failed to create UIImage from data.")
                                    return nil // Skip this item
                                }
                                
                                // 3. Resize Image
                                let resizedImage = await self.resizeImage(image: originalImage, targetMaxDimension: maxDimension)
                                
                                // 4. Compress to JPEG Data
                                guard let compressedData = await resizedImage.jpegData(compressionQuality: compressionQuality) else {
                                    print("Failed to compress image to JPEG.")
                                    return nil // Skip this item
                                }
                                
                                print("Successfully processed one image (Original: \(originalData.count / 1024) KB, Compressed: \(compressedData.count / 1024) KB)")
                                return compressedData // Return the processed data
                                
                            } catch {
                                print("Error processing one image: \(error)")
                                return nil // Skip this item on error
                            }
                        }
                    }
                    // Collect results as they complete
                    for try await dataOrNil in group {
                        if let data = dataOrNil {
                            processedData.append(data)
                        } else {
                            loadErrors.append("Failed to process one image.")
                        }
                    }
                }
                // Update state on main thread after all tasks complete
                await MainActor.run {
                    selectedImageData = processedData // Store the processed data
                    isLoadingImages = false
                    print("Finished processing images. Loaded \(selectedImageData.count) images successfully.")
                    if !loadErrors.isEmpty {
                         imageSelectionError = "\(loadErrors.count) image(s) could not be processed."
                         print("Warning: \(loadErrors.count) errors during image processing.")
                     }
                }
            } catch {
                // Handle errors from the task group itself (less likely here)
                await MainActor.run {
                     imageSelectionError = error.localizedDescription
                     isLoadingImages = false
                     print("Error during image loading task group: \(error)")
                }
            }
        }
    }
    
    // Helper function to resize UIImage, running on a background actor
    private func resizeImage(image: UIImage, targetMaxDimension: CGFloat) async -> UIImage {
        return await Task.detached(priority: .userInitiated) { // Perform resizing off the main thread
            let size = image.size
            let aspectRatio = size.width / size.height
            var newSize: CGSize

            if size.width > targetMaxDimension || size.height > targetMaxDimension {
                if aspectRatio > 1 {
                    // Landscape or square
                    newSize = CGSize(width: targetMaxDimension, height: targetMaxDimension / aspectRatio)
                } else {
                    // Portrait
                    newSize = CGSize(width: targetMaxDimension * aspectRatio, height: targetMaxDimension)
                }
            } else {
                // Image is already smaller than target, return original
                return image 
            }

            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            
            return resizedImage
        }.value // Get the result from the detached task
    }

    // Function to upload images to Supabase Storage and then call Edge Function
    private func startTraining() {
        guard hasEnoughImages, !isSubmittingTraining else { return }
        guard let userId = authManager.session?.user.id else {
            submissionError = "Error: Not authenticated (missing user ID)."
            print("Start Training Error: Missing user ID")
            return
        }
        guard let accessToken = authManager.session?.accessToken else {
            submissionError = "Error: Not authenticated (missing access token)."
            print("Start Training Error: Missing access token")
            return
        }

        print("Starting storage upload for \(selectedImageData.count) images...")
        isSubmittingTraining = true
        submissionMessage = "Uploading images..."
        submissionError = nil
        let uploadStartDate = Date()

        Task {
            var uploadedImageUrls: [String] = []
            var uploadErrors: [String] = []
            let bucketName = "training-images" // Match bucket name created in Supabase

            do {
                // Upload images sequentially instead of concurrently
                for (index, imageData) in selectedImageData.enumerated() {
                    // Generate unique path within user's folder
                    let fileExtension = detectImageExtension(from: imageData) ?? "jpg" // Basic extension detection
                    let filePath = "\(userId.uuidString)/training_\(Date().timeIntervalSince1970)_\(index).\(fileExtension)"
                    print("Uploading image \(index + 1)/\(selectedImageData.count) to: \(filePath)")
                    
                    // Update UI state for current upload
                    let uploadIndex = index + 1
                    await MainActor.run {
                        submissionMessage = "Uploading image \(uploadIndex) of \(selectedImageData.count)..."
                    }

                    do {
                        // Use Supabase Storage client
                        let fileOptions = FileOptions(cacheControl: "3600", upsert: false)
                        
                        // Perform the upload and wait for it to complete
                        _ = try await supabase.storage
                            .from(bucketName)
                            .upload(path: filePath, file: imageData, options: fileOptions)
                        
                        // Get a Signed URL instead of Public URL
                        let signedUrlResponse = try await supabase.storage
                             .from(bucketName)
                             .createSignedURL(path: filePath, expiresIn: 300) // 5 minutes validity
                        
                        print("Upload success for \(filePath). Signed URL: \(signedUrlResponse)")
                        uploadedImageUrls.append(signedUrlResponse.absoluteString) // Add successful URL
                        
                    } catch {
                        print("Error uploading image \(index + 1) to \(filePath): \(error.localizedDescription)")
                        // If one fails, stop the whole process
                        throw NSError(domain: "AppError", code: 11, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image \(uploadIndex): \(error.localizedDescription)"])
                    }
                } // End of for loop
                    
                let uploadDuration = Date().timeIntervalSince(uploadStartDate)
                print("Finished image uploads sequentially in \(String(format: "%.2f", uploadDuration)) seconds. \(uploadedImageUrls.count)/\(selectedImageData.count) successful.")

                // Check if all uploads were successful (already handled by throwing error in loop)
                // guard uploadedImageUrls.count == selectedImageData.count else {
                //     throw NSError(domain: "AppError", code: 10, userInfo: [NSLocalizedDescriptionKey: "Failed to upload all images (\(uploadErrors.count) errors)."])
                // }
                
                // Update UI state after uploads
                 await MainActor.run {
                     submissionMessage = "Uploads complete. Initiating training..."
                 }
               
                // ---- Now call the Edge Function with URLs ----
               
                // 1. Construct Request Body with URLs
                 let body: [String: Any] = ["imageUrls": uploadedImageUrls] // Send URLs now
                guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                    throw NSError(domain: "AppError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body."])
                }
               
                // 2. Get Edge Function URL
                 guard let supabaseUrlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
                       let supabaseUrl = URL(string: supabaseUrlString),
                       let projectRef = supabaseUrl.host?.split(separator: ".").first
                 else {
                    throw NSError(domain: "AppError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not determine Supabase project reference."])
                 }
                 let functionUrlString = "https://\(projectRef).supabase.co/functions/v1/train-lora"
                 guard let functionUrl = URL(string: functionUrlString) else {
                    throw NSError(domain: "AppError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid function URL."])
                 }

                // 3. Create URLRequest (Most headers remain the same)
                var request = URLRequest(url: functionUrl)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                 guard let anonKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
                     throw NSError(domain: "AppError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Supabase Anon Key not found."])
                 }
                 request.setValue(anonKey, forHTTPHeaderField: "apikey")
                request.httpBody = bodyData // Body now contains URLs
               
                // Set a reasonable timeout for the function call itself (zipping/Fal submit)
                 request.timeoutInterval = 60 // e.g., 60 seconds

                // 4. Perform URLSession Data Task
                print("Sending request to Edge Function: \(functionUrlString)")
                let (data, response) = try await URLSession.shared.data(for: request)
               
                // 5. Handle Response (Same logic as before)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "NetworkError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Invalid response from edge function."])
                }
                print("Received response status from edge function: \(httpResponse.statusCode)")
               
                if (200...299).contains(httpResponse.statusCode) {
                    let responseJson = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let message = responseJson?["message"] as? String ?? "Training initiated (no message)."
                    let requestId = responseJson?["requestId"] as? String ?? "N/A"
                    print("Training success response: \(message), Request ID: \(requestId)")
                     await MainActor.run {
                         isSubmittingTraining = false
                         submissionMessage = message + " You will be notified upon completion."
                         // Disable button permanently? Navigate away?
                    }
                } else {
                    let errorBody = String(data: data, encoding: .utf8) ?? "No error details"
                    print("Edge function HTTP error \(httpResponse.statusCode): \(errorBody)")
                    throw NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to start training. Server error: \(errorBody)"])
                }
               
            } catch {
                // Handle errors from upload or function call
                print("Error in startTraining process: \(error.localizedDescription)")
                 await MainActor.run {
                     isSubmittingTraining = false
                     // Report the specific error that occurred
                     submissionError = "Error: \(error.localizedDescription)"
                 }
            }
        }
    }

    // Helper to detect basic image type from Data (can be improved)
    private func detectImageExtension(from data: Data) -> String? {
        var values = [UInt8](repeating: 0, count: 2)
        data.copyBytes(to: &values, count: 2)
        
        if values == [0xFF, 0xD8] { return "jpg" }
        if values == [0x89, 0x50] { return "png" }
        // Add checks for GIF, etc. if needed
        return nil // Default or indicate unknown
    }
}

#Preview {
    // Wrap in NavigationView for preview title/toolbar
    NavigationView {
        TrainingScreen()
            .environmentObject(AuthManager()) // Provide dummy AuthManager for preview
    }
    // Provide dummy values for Supabase URL/Key in preview if needed
     // Or mock the network request layer for previews
}

// Make sure the Color hex extension is available in your project
// extension Color { ... } // Add if needed 
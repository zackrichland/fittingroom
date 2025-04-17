import SwiftUI
import Supabase // Ensure Supabase is imported

class OpenAIService {
    static let shared = OpenAIService()
    private var apiKey: String = ""
    
    private init() {}
    
    func configure(withApiKey key: String) {
        self.apiKey = key
    }
    
    func generateOutfitImage(selfie: UIImage, wardrobeItems: [UIImage]) async throws -> UIImage {
        // Convert images to base64
        guard let selfieBase64 = selfie.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
            throw OpenAIError.imageConversionFailed
        }
        
        let itemImagesBase64 = try wardrobeItems.map { image in
            guard let base64 = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
                throw OpenAIError.imageConversionFailed
            }
            return base64
        }
        
        // Construct the prompt
        let prompt = """
        Create a photorealistic image showing how this person would look wearing the provided clothing items. 
        Maintain the person's facial features, pose, and background while naturally integrating the clothing items.
        Ensure high-quality, realistic lighting and shadows for a seamless blend.
        """
        
        // Negative prompt to avoid common issues
        let negativePrompt = """
        deformed, distorted, unrealistic, poor quality, low resolution, blurry, 
        artificial looking, unnatural lighting, bad anatomy, watermarks, text, 
        duplicate items, missing limbs, extra limbs
        """
        
        // Construct the API request
        let _ = [
            "model": "dall-e-3",
            "prompt": prompt,
            "negative_prompt": negativePrompt,
            "n": 1,
            "size": "1024x1024",
            "quality": "hd",
            "response_format": "b64_json",
            "user_images": [selfieBase64] + itemImagesBase64
        ] as [String: Any]
        
        // TODO: Replace with actual API call
        // For now, return the original selfie as a placeholder
        return selfie
    }
    
    enum OpenAIError: Error {
        case imageConversionFailed
        case apiError(String)
        case invalidResponse
    }
}

enum OpenAIError: Error {
    case missingAPIKey
    case invalidResponse
    case generationFailed
}

struct Look: Identifiable {
    let id: String
    let image: UIImage
    let items: [WardrobeItem]
    let createdAt: Date
    
    init(id: String = UUID().uuidString, image: UIImage, items: [WardrobeItem], createdAt: Date = Date()) {
        self.id = id
        self.image = image
        self.items = items
        self.createdAt = createdAt
    }
}

struct LooksScreen: View {
    @EnvironmentObject private var lookManager: LookManager
    
    // Add init for nav bar styling
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        // Apply appearance to the navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Change background to white
                Color.white.edgesIgnoringSafeArea(.all)
                
                if lookManager.looks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No saved looks yet")
                            .font(.headline)
                            .foregroundColor(.black) // Change text color
                        
                        Text("Your generated outfits will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    // Use system background color for scroll view on white theme
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(lookManager.looks) { look in
                                LookCard(look: look)
                                    // Add environment object if LookCard needs it and doesn't get it implicitly
                                    .environmentObject(lookManager)
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemBackground)) // Use system background
                }
            }
            .navigationTitle("Saved Looks")
            .navigationBarTitleDisplayMode(.inline)
             // Removed toolbarColorScheme(.dark) if it was present
        }
         // Removed preferredColorScheme(.dark) if it was present
    }
}

struct LookCard: View {
    let look: Look
    @EnvironmentObject private var lookManager: LookManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) { // Changed alignment for delete button
                 // Use system background for card background
                 RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground)) // Use secondary background
                    .aspectRatio(1, contentMode: .fit)
                
                Image(uiImage: look.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped() // Ensure image stays within bounds
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Keep delete button styling for contrast
                Button(action: {
                    lookManager.deleteLook(look)
                }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(6) // Adjust padding slightly
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(8) // Add padding to position button from corner
                 // Removed explicit position
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(look.items.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.primary) // Use primary text color
                    .lineLimit(2)
                
                Text(look.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary) // Use secondary text color
            }
            .padding(.horizontal, 4)
        }
    }
}

@main
struct FittingRoomApp: App {
    @StateObject private var wardrobeManager = WardrobeManager()
    @StateObject private var lookManager = LookManager()
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
             // Use AuthManager's published properties to drive the view hierarchy
             if authManager.isAuthenticated {
                 // If authenticated, check if training is needed
                 if authManager.needsTraining {
                     // Show TrainingScreen if fal_lora_model_id is missing
                     TrainingScreen()
                         .environmentObject(authManager) // Pass AuthManager down
                         // Pass other managers if needed by TrainingScreen
                         // .environmentObject(wardrobeManager)
                         // .environmentObject(lookManager)
                 } else {
                     // Show main ContentView if profile exists and model ID is present
                     ContentView(isAuthenticated: $authManager.isAuthenticated)
                         .environmentObject(authManager) // Pass AuthManager down
                         .environmentObject(wardrobeManager)
                         .environmentObject(lookManager)
                 }
             } else {
                  // Show AuthScreen if not authenticated
                  AuthScreen(isAuthenticated: $authManager.isAuthenticated)
                     .environmentObject(authManager) // Pass AuthManager down
                     // AuthScreen likely doesn't need other managers
             }
        }
    }
}

class WardrobeManager: ObservableObject {
    @Published var wardrobeItems: [WardrobeItem] = []
    
    func addItem(_ item: WardrobeItem) {
        wardrobeItems.append(item)
    }
}

class LookManager: ObservableObject {
    @Published var looks: [Look] = []
    
    func addLook(image: UIImage, items: [WardrobeItem]) {
        let look = Look(image: image, items: items)
        looks.append(look)
    }
    
    func deleteLook(_ look: Look) {
        looks.removeAll { $0.id == look.id }
    }
}

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    @EnvironmentObject private var lookManager: LookManager
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        if isAuthenticated {
            TabView {
                HomeScreen()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                WardrobeScreen()
                    .tabItem {
                        Label("Wardrobe", systemImage: "tshirt.fill")
                    }
                
                LooksScreen()
                    .tabItem {
                        Label("Looks", systemImage: "photo.on.rectangle.angled")
                    }
            }
        } else {
            AuthScreen(isAuthenticated: $isAuthenticated)
        }
    }
}

#Preview {
    ContentView(isAuthenticated: .constant(true))
        .environmentObject(WardrobeManager())
        .environmentObject(LookManager())
}

// --- Simple AuthManager Example ---
// (You might have a more complex one already)
// This observable object listens to Supabase auth changes
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var session: Session? = nil // Store the user session
    @Published var userProfile: UserProfile? = nil // Store fetched profile
    @Published var needsTraining: Bool = false // True if fal_lora_model_id is null

    private var authListenerTask: Task<Void, Never>? = nil

    init() {
        Task {
            await checkInitialSession()
            listenToAuthState()
        }
    }

    deinit {
        authListenerTask?.cancel()
        print("AuthManager deinit: Cancelled listener task.")
    }

     func checkInitialSession() async {
        do {
            let currentSession = try await supabase.auth.session
            print("Initial check: User is signed in. User ID: \(currentSession.user.id.uuidString)")
            // Set session and auth state first
            await MainActor.run { 
                self.session = currentSession
                self.isAuthenticated = true
            }
            // Now check the profile
            await checkUserProfile(userId: currentSession.user.id)
        } catch {
            print("Initial check: User is not signed in or session expired.")
             await MainActor.run {
                 self.session = nil
                 self.isAuthenticated = false
                 self.userProfile = nil // Clear profile on sign out
                 self.needsTraining = false // Reset training state
             }
        }
    }

    func listenToAuthState() {
         print("AuthManager: Starting auth state listener task.")
         authListenerTask = Task {
            for await (event, session) in supabase.auth.authStateChanges {
                 guard !Task.isCancelled else {
                     print("AuthManager: Listener task cancelled.")
                     return
                 }
                 
                print("AuthManager: Received auth event: \(event)")
                
                // Store the latest session immediately for profile check
                 let latestSession = session
                 let userId = latestSession?.user.id
                 
                await MainActor.run { // Update basic auth state on main thread
                     switch event {
                         case .signedIn, .tokenRefreshed:
                            print("Auth event: Signed In or Token Refreshed. User ID: \(userId?.uuidString ?? "nil")")
                             self.session = latestSession
                             self.isAuthenticated = true
                             // Needs profile check will happen below
                         case .signedOut:
                             print("Auth event: Signed Out.")
                             self.session = nil
                             self.isAuthenticated = false
                             self.userProfile = nil // Clear profile
                             self.needsTraining = false // Reset training state
                         case .passwordRecovery, .userUpdated, .userDeleted:
                            // Handle these cases as needed, update session/auth state
                             print("Auth event: \(event). User ID: \(userId?.uuidString ?? "nil")")
                             self.session = latestSession // Update session if needed
                             // Reset state if user is deleted or signed out implicitly
                             if event == .userDeleted || latestSession == nil {
                                 self.isAuthenticated = false
                                 self.userProfile = nil
                                 self.needsTraining = false
                             } else {
                                 self.isAuthenticated = latestSession != nil
                             }
                         @unknown default:
                             print("Auth event: Unknown state.")
                     }
                 }
                 
                 // After basic auth state is set, check profile if user is signed in
                 if let currentUserId = userId, (event == .signedIn || event == .tokenRefreshed || event == .userUpdated) {
                     print("Auth event triggered profile check for user: \(currentUserId.uuidString)")
                     await checkUserProfile(userId: currentUserId)
                 }
             }
             print("AuthManager: Auth state listener loop finished.")
         }
    }

    // Function to fetch the user profile from the database
    func checkUserProfile(userId: UUID) async {
        print("Checking profile for user: \(userId.uuidString)")
        do {
            // Fetch the profile row where the id matches the logged-in user's id
            let fetchedProfile: UserProfile = try await supabase.database
                .from("profiles") // Use the exact table name
                .select() // Select all columns (*) for this profile
                .eq("id", value: userId) // Filter where id column matches userId
                .single() // Expect exactly one row (or throw error)
                .execute()
                .value // Decode the result into our UserProfile struct
            
            print("Successfully fetched profile. Fal LoRA ID: \(fetchedProfile.fal_lora_model_id ?? "NULL")")
            // Update state on the main thread
            await MainActor.run {
                self.userProfile = fetchedProfile
                 // Set needsTraining based on whether the fal_lora_model_id is nil
                self.needsTraining = (fetchedProfile.fal_lora_model_id == nil)
                print("Profile check complete. Needs training: \(self.needsTraining)")
            }
        } catch {
            // Handle errors (e.g., profile not found yet, network issue)
            print("Error fetching profile for user \(userId.uuidString): \(error.localizedDescription)")
            // If profile doesn't exist yet (common right after sign up trigger), assume training is needed
            await MainActor.run {
                self.userProfile = nil // No profile found
                 // Consider the user needs training if profile fetch fails
                 // (Might need refinement if errors are persistent network issues)
                self.needsTraining = true 
                 print("Profile fetch failed. Assuming training needed.")
            }
        }
    }
}


// --- Dummy signIn function if needed elsewhere (remove if not used) ---
// func signIn() {
//     // Placeholder - actual sign-in logic is now in AuthScreen/AuthManager
//     print("Dummy signIn called - logic should be handled elsewhere.")
// } 
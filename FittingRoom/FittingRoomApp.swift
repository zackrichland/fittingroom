import SwiftUI

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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a1a1a").edgesIgnoringSafeArea(.all)
                
                if lookManager.looks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No saved looks yet")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Your generated outfits will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(lookManager.looks) { look in
                                LookCard(look: look)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Looks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LookCard: View {
    let look: Look
    @EnvironmentObject private var lookManager: LookManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(1, contentMode: .fit)
                
                Image(uiImage: look.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button(action: {
                    lookManager.deleteLook(look)
                }) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .position(x: 30, y: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(look.items.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(look.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
    }
}

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func signIn() {
        isAuthenticated = true
    }
    
    func signOut() {
        isAuthenticated = false
    }
}

@main
struct FittingRoomApp: App {
    @StateObject private var wardrobeManager = WardrobeManager()
    @StateObject private var lookManager = LookManager()
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wardrobeManager)
                .environmentObject(lookManager)
                .environmentObject(authManager)
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
    
    var body: some View {
        if authManager.isAuthenticated {
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
            AuthScreen(isAuthenticated: $authManager.isAuthenticated)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WardrobeManager())
        .environmentObject(LookManager())
} 
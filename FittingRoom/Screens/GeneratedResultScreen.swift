import SwiftUI
import UIKit

struct GeneratedResultScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var lookManager: LookManager
    @State private var isSaved = false
    @State private var isGenerating = true
    @State private var generatedImage: UIImage?
    @State private var showShareSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let items: [WardrobeItem]
    
    var body: some View {
        VStack(spacing: 0) {
            // Generated image area
            ZStack {
                Color(hex: "1d1d1d")
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Rectangle()
                            .fill(
                                Color.white.opacity(0.05)
                            )
                            .allowsHitTesting(false)
                    )
                
                if isGenerating {
                    VStack(spacing: 24) {
                        // Loading animation
                        ZStack {
                            Circle()
                                .stroke(Color(hex: "f3c7e1").opacity(0.2), lineWidth: 8)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color(hex: "fc1657"), lineWidth: 8)
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(isGenerating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 1)
                                        .repeatForever(autoreverses: false),
                                    value: isGenerating
                                )
                        }
                        
                        VStack(spacing: 8) {
                            Text("Creating your outfit")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("This may take a few moments...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                } else if let image = generatedImage {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Generated image
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            // Outfit details
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Outfit Details")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ForEach(Array(items), id: \.id) { item in
                                    HStack {
                                        Image(systemName: item.imageName)
                                            .foregroundColor(Color(hex: "fc1657"))
                                        
                                        Text(item.name)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text(item.category.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding()
                    }
                }
            }
            
            // Action buttons
            VStack(spacing: 16) {
                // Primary actions
                HStack(spacing: 16) {
                    // Save button
                    Button(action: {
                        if let image = generatedImage {
                            lookManager.addLook(image: image, items: items)
                            isSaved = true
                        }
                    }) {
                        HStack {
                            Image(systemName: isSaved ? "checkmark" : "square.and.arrow.down")
                            Text(isSaved ? "Saved" : "Save")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSaved ? Color.green : Color(hex: "fc1657"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isSaved)
                    
                    // Share button
                    Button(action: {
                        showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.headline)
                        .foregroundColor(Color(hex: "fc1657"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "fc1657"), lineWidth: 1)
                        )
                    }
                }
                
                // Secondary actions
                HStack(spacing: 16) {
                    // Regenerate button
                    Button(action: {
                        regenerateOutfit()
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Try Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Back button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
            .background(Color(hex: "1a1a1a"))
        }
        .navigationTitle("Your Outfit")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let image = generatedImage {
                ShareSheet(items: [image])
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            generateOutfit()
        }
    }
    
    private func generateOutfit() {
        isGenerating = true
        
        Task {
            do {
                let itemImages = items.compactMap { $0.image }
                // TODO: Update this call to use the Digital Twin instead of the selfie
                // Temporarily, we might need to pass a placeholder or modify OpenAIService
                // For now, let's assume it will be handled later or comment it out to compile
                // let image = try await OpenAIService.shared.generateOutfitImage(selfie: selfie, wardrobeItems: itemImages)
                
                // Placeholder image until generation logic is updated
                let placeholderImage = UIImage(systemName: "photo.artframe") ?? UIImage()
                
                await MainActor.run {
                    // generatedImage = image
                    generatedImage = placeholderImage // Use placeholder
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isGenerating = false
                }
            }
        }
    }
    
    private func regenerateOutfit() {
        isGenerating = true
        generatedImage = nil
        generateOutfit()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        GeneratedResultScreen(
            items: [
                WardrobeItem(name: "Blue T-Shirt", imageName: "tshirt.fill", category: .top),
                WardrobeItem(name: "Black Jeans", imageName: "staroflife", category: .bottom)
            ]
        )
        .environmentObject(LookManager())
    }
} 
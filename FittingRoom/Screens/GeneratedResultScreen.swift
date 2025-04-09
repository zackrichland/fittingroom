import SwiftUI

struct GeneratedResultScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSaved = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Generated image placeholder
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .frame(height: 400)
                    
                    VStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .foregroundColor(.gray)
                        
                        Text("Generated Outfit Preview")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        // Placeholder loading text
                        Text("This is where the AI-generated outfit would appear")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Rating system
            HStack(spacing: 20) {
                ForEach(1...5, id: \.self) { rating in
                    Button(action: {
                        // TODO: Implement rating system
                    }) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Text("Rate this outfit")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
            
            // Action buttons
            HStack(spacing: 16) {
                // Save button
                Button(action: {
                    // TODO: Implement save logic
                    isSaved = true
                }) {
                    HStack {
                        Image(systemName: isSaved ? "checkmark" : "square.and.arrow.down")
                        Text(isSaved ? "Saved" : "Save")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSaved ? Color.green : Color.blue)
                    .cornerRadius(8)
                }
                
                // Regenerate button
                Button(action: {
                    // TODO: Implement regenerate logic
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal)
            
            // Back button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Home")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
            .padding(.bottom)
        }
        .navigationTitle("Your Outfit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        GeneratedResultScreen()
    }
} 
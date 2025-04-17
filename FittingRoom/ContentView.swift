import SwiftUI
import Supabase

// Placeholder for the main content view after authentication
struct ContentView: View {
     @Binding var isAuthenticated: Bool // Needs binding to allow sign-out

     var body: some View {
         VStack {
            Text("Welcome!")
                 .font(.largeTitle)
                 .padding()

            Text("You are signed in.")

             Spacer() // Push button to bottom

             // Add a Sign Out button
            Button("Sign Out") {
                 signOut()
             }
             .buttonStyle(.borderedProminent)
             .tint(.red) // Make sign out button red
             .padding()
         }
         .navigationTitle("Home") // Example title
         .navigationBarBackButtonHidden(true) // Hide back button when signed in
         // Add other content here...
         // TODO: Check for fal_lora_model_id and navigate to training if needed
         // TODO: Add navigation to the main app features (wardrobe, try-on etc.)
     }

     func signOut() {
         Task {
             do {
                 try await supabase.auth.signOut()
                 print("Successfully signed out.")
                 // The AuthManager listener will set isAuthenticated to false
             } catch {
                 print("Error signing out: \(error.localizedDescription)")
                 // Optionally show an error message to the user
             }
         }
     }
}

#Preview {
    // Preview requires a binding
     ContentView(isAuthenticated: .constant(true))
         // Provide dummy environment objects if ContentView uses them
         // .environmentObject(AuthManager())
         // .environmentObject(WardrobeManager())
         // .environmentObject(LookManager())
} 
import SwiftUI

struct AuthScreen: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "tshirt.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 50)
            
            Text("FittingRoom.ai")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Your personal virtual wardrobe")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: {
                    // For now, just sign in without validation
                    withAnimation {
                        authManager.signIn()
                    }
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // TODO: Implement sign up navigation
                }) {
                    Text("Create Account")
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
            
            Spacer()
            
            // Terms and privacy footer
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

#Preview {
    AuthScreen(isAuthenticated: .constant(false))
        .environmentObject(AuthManager())
} 
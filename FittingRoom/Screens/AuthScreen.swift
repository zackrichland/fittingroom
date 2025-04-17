import SwiftUI
import Supabase

struct AuthScreen: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1a1a1a").ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "tshirt.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color(hex: "ea2190"))
                        .padding(.top, 30)
                    
                    Text("FittingRoom.ai")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your personal virtual wardrobe")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "f3c7e1"))
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .colorScheme(.dark)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .colorScheme(.dark)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }

                        Button(action: {
                            signIn()
                        }) {
                            HStack {
                                 Spacer()
                                 if isLoading {
                                     ProgressView()
                                         .tint(.white)
                                 } else {
                                     Text("Sign In")
                                         .font(.headline)
                                 }
                                 Spacer()
                             }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLoading ? Color.gray : Color.blue)
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)
                        
                        NavigationLink(destination: SignUpView()) {
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
                    
                    Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .padding()
                .navigationBarHidden(true)
            }
        }
        .navigationViewStyle(.stack)
    }

    func signIn() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let session = try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                print("Successfully signed in! User ID: \(session.user.id)")
                isLoading = false

            } catch {
                print("Error signing in: \(error.localizedDescription)")
                await MainActor.run {
                     errorMessage = error.localizedDescription
                     isLoading = false
                 }
            }
        }
    }
}

#Preview {
    AuthScreen(isAuthenticated: .constant(false))
} 
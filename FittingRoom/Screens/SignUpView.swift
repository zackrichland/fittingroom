import SwiftUI
import Supabase

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showConfirmationAlert = false

    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var body: some View {
        // Add a ZStack for background color
         ZStack {
             // Use a dark background consistent with AuthScreen (adjust color if needed)
             Color(hex: "1a1a1a").ignoresSafeArea()
             
            VStack(spacing: 20) {
                 Text("Create your account")
                    .font(.title2).bold()
                     .foregroundColor(.white) // Ensure title is visible
                    .padding(.bottom)
                    .padding(.top, 30)

                TextField("Email", text: $email)
                    .padding()
                     // Use a slightly lighter background for text fields
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                     .colorScheme(.dark) // Hint for keyboard appearance

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                     .colorScheme(.dark)

                 SecureField("Confirm Password", text: $confirmPassword)
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

                Button {
                    signUp()
                } label: {
                     HStack {
                        Spacer()
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                     // Change background based on loading and password match
                    .background(isLoading ? Color.gray : (passwordsMatch ? Color.blue : Color.gray))
                    .cornerRadius(8)
                }
                .disabled(isLoading || !passwordsMatch) // Disable if loading or passwords don't match
                .padding(.top)
                
                Spacer() // Push content to top
            }
            .padding()
        }
         // Use inline navigation title
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
         // Style navigation bar for dark background
         .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Check Your Email", isPresented: $showConfirmationAlert, actions: {
             Button("OK", role: .cancel) {
                 // Dismiss the sign up view after showing the alert
                 presentationMode.wrappedValue.dismiss()
             }
        }, message: {
            Text("We've sent a confirmation link to \(email). Please check your inbox (and spam folder) to activate your account.")
        })
    }

    func signUp() {
        guard passwordsMatch else {
            errorMessage = "Passwords do not match."
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                // Use the global supabase client instance
                // By default, Supabase sends a confirmation email.
                _ = try await supabase.auth.signUp(
                    email: email,
                    password: password
                    // You can add additional user metadata here if needed:
                    // data: ["username": "initial_username"]
                )

                print("Sign up initiated. Check email for confirmation.")
                // Ensure UI updates are on main thread before presenting alert
                 await MainActor.run {
                     isLoading = false
                     showConfirmationAlert = true // Show the confirmation message
                 }

            } catch {
                print("Error signing up: \(error.localizedDescription)")
                 await MainActor.run {
                     errorMessage = error.localizedDescription
                     isLoading = false
                 }
            }
        }
    }
}

#Preview {
    // Embed SignUpView in NavigationView for preview
     NavigationView {
         SignUpView()
     }
} 
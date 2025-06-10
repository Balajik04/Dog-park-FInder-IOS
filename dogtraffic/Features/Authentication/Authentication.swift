
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Your App Logo
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(AppColors.parkGreen)
                .padding(.bottom, 30)

            Text("Welcome to Dog Park Finder")
                .font(.largeTitle).fontWeight(.bold).foregroundColor(AppColors.textPrimary)

            Text("Sign in to find and share info about dog parks.")
                .font(.headline).fontWeight(.regular).foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 40)
            
            Spacer()

            if authViewModel.isLoading {
                ProgressView("Please wait...").padding()
            } else if authViewModel.isShowingVerificationCodeInput {
                verificationCodeInputView
            } else {
                signInOptionsView
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red).padding().multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.appBackground.ignoresSafeArea())
    }
    
    // View for Phone/Google sign-in options
    private var signInOptionsView: some View {
        VStack(spacing: 20) {
            TextField("Enter phone number (e.g., +15551234567)", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
            
            Button {
                authViewModel.sendVerificationCode(phoneNumber: phoneNumber)
            } label: {
                Text("Sign in with Phone")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity).frame(height: 55)
                    .background(AppColors.skyBlue).foregroundColor(.white).cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Text("or").foregroundColor(.gray)
            
            // Google Sign-In Button
            Button {
                // MODIFICATION: Call the async function from within a Task
                Task {
                    await authViewModel.signInWithGoogle()
                }
            } label: {
                HStack {
                    // Make sure you have a 'google_logo' image in your Assets
                    Image("google_logo")
                        .resizable().scaledToFit().frame(width: 24, height: 24)
                    Text("Sign in with Google")
                        .fontWeight(.medium)
                        .foregroundColor(.black.opacity(0.8))
                }
                .frame(maxWidth: .infinity).frame(height: 55)
                .background(Color.white).cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 40)
        }
    }
    
    // View for entering the verification code from SMS
    private var verificationCodeInputView: some View {
        VStack(spacing: 20) {
            Text("Enter the code sent to \(phoneNumber)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            TextField("6-digit code", text: $verificationCode)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
            
            Button {
                authViewModel.verifyCode(verificationCode: verificationCode)
            } label: {
                Text("Verify Code")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity).frame(height: 55)
                    .background(AppColors.parkGreen).foregroundColor(.white).cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Button("Use a different phone number") {
                authViewModel.isShowingVerificationCodeInput = false
            }
            .font(.caption)
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthViewModel())
    }
}

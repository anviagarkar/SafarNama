import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onComplete: () -> Void
    @State private var email = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case email
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Forgot Password")
                        .font(AppTheme.Font.displayLarge)
                        .foregroundStyle(AppTheme.Colour.inkDark)

                    Text("Enter your email and we'll send you a code to reset your password.")
                        .font(AppTheme.Font.handwritingMedium)
                        .foregroundStyle(AppTheme.Colour.inkDark)
                        .multilineTextAlignment(.center)

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.go)
                        .onSubmit { sendCodeTapped() }
                        .padding()
                        .background(AppTheme.Colour.surface)
                        .cornerRadius(AppTheme.Radius.md)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(AppTheme.Font.handwritingSmall)
                    }

                    Button {
                        sendCodeTapped()
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Send Code")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colour.inkDark)
                    .foregroundStyle(.white)
                    .cornerRadius(AppTheme.Radius.md)
                    .disabled(authViewModel.isLoading || email.isEmpty)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(isPresented: $authViewModel.forgotPasswordSuccess) {
                ResetPasswordView(authViewModel: authViewModel, onComplete: onComplete)
            }
        }
    }

    private func sendCodeTapped() {
        focusedField = nil
        Task {
            await authViewModel.forgotPassword(email: email)
        }
    }
}

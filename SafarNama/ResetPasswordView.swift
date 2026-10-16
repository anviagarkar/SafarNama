import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onComplete: () -> Void
    @State private var code = ""
    @State private var newPassword = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case code, newPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Reset Password")
                    .font(AppTheme.Font.displayLarge)
                    .foregroundStyle(AppTheme.Colour.inkDark)

                Text("Enter the code we sent you and choose a new password.")
                    .font(AppTheme.Font.handwritingMedium)
                    .foregroundStyle(AppTheme.Colour.inkDark)
                    .multilineTextAlignment(.center)

                TextField("6-digit code", text: $code)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .code)
                    .onChange(of: code) { _, newValue in
                        if newValue.count > 6 {
                            code = String(newValue.prefix(6))
                        }
                        if code.count == 6 {
                            focusedField = .newPassword
                        }
                    }
                    .padding()
                    .background(AppTheme.Colour.surface)
                    .cornerRadius(AppTheme.Radius.md)

                SecureField("New password", text: $newPassword)
                    .focused($focusedField, equals: .newPassword)
                    .submitLabel(.go)
                    .onSubmit { resetTapped() }
                    .padding()
                    .background(AppTheme.Colour.surface)
                    .cornerRadius(AppTheme.Radius.md)

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(AppTheme.Font.handwritingSmall)
                }

                Button {
                    resetTapped()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Reset Password")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colour.inkDark)
                .foregroundStyle(.white)
                .cornerRadius(AppTheme.Radius.md)
                .disabled(authViewModel.isLoading || code.isEmpty || newPassword.isEmpty)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: authViewModel.resetPasswordSuccess) { _, success in
            if success {
                onComplete()
            }
        }
    }

    private func resetTapped() {
        focusedField = nil
        Task {
            await authViewModel.resetPassword(token: code, newPassword: newPassword)
        }
    }
}

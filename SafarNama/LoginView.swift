import SwiftUI
import SwiftData

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Safarnama")
                        .font(AppTheme.Font.displayLarge)
                        .foregroundStyle(AppTheme.Colour.inkDark)

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                        .padding()
                        .background(AppTheme.Colour.surface)
                        .cornerRadius(AppTheme.Radius.md)

                    SecureField("Password", text: $password)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit { loginTapped() }
                        .padding()
                        .background(AppTheme.Colour.surface)
                        .cornerRadius(AppTheme.Radius.md)

                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            showingForgotPassword = true
                        }
                        .font(AppTheme.Font.handwritingMedium)
                    }

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(AppTheme.Font.handwritingSmall)
                    }

                    Button {
                        loginTapped()
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Log In")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colour.inkDark)
                    .foregroundStyle(.white)
                    .cornerRadius(AppTheme.Radius.md)
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)

                    Button("Don't have an account? Sign up") {
                        showingSignUp = true
                    }
                    .font(AppTheme.Font.handwritingMedium)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .sheet(isPresented: $showingSignUp) {
                SignUpView(authViewModel: authViewModel)
            }
            .sheet(isPresented: $showingForgotPassword, onDismiss: {
                authViewModel.forgotPasswordSuccess = false
                authViewModel.resetPasswordSuccess = false
            }) {
                ForgotPasswordView(authViewModel: authViewModel, onComplete: {
                    showingForgotPassword = false
                })
            }
        }
    }

    private func loginTapped() {
        focusedField = nil
        Task {
            await authViewModel.login(email: email, password: password, modelContext: modelContext)
        }
    }
}

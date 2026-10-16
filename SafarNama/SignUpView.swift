import SwiftUI
import SwiftData

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?

    enum Field {
        case name, email, password, confirmPassword
    }

    var passwordsMatch: Bool {
        confirmPassword.isEmpty || password == confirmPassword
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    Text("Create your account")
                        .font(AppTheme.Font.displayMedium)
                        .foregroundStyle(AppTheme.Colour.inkDark)

                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }
                        .padding()
                        .background(AppTheme.Colour.surface)
                        .cornerRadius(AppTheme.Radius.md)

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
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmPassword }
                        .padding()
                        .background(AppTheme.Colour.surface)
                        .cornerRadius(AppTheme.Radius.md)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit { signUpTapped() }
                        .padding()
                        .background(AppTheme.Colour.surface)
                        .cornerRadius(AppTheme.Radius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(passwordsMatch ? Color.clear : Color.red, lineWidth: 1)
                        )

                    if !passwordsMatch {
                        Text("Passwords don't match")
                            .foregroundStyle(.red)
                            .font(AppTheme.Font.handwritingSmall)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.white)
                            .font(AppTheme.Font.handwritingMedium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(AppTheme.Radius.md)
                    }

                    Button {
                        signUpTapped()
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Sign Up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colour.inkDark)
                    .foregroundStyle(.white)
                    .cornerRadius(AppTheme.Radius.md)
                    .disabled(
                        authViewModel.isLoading
                        || email.isEmpty
                        || password.isEmpty
                        || name.isEmpty
                        || confirmPassword.isEmpty
                        || password != confirmPassword
                    )
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func signUpTapped() {
        guard password == confirmPassword else { return }
        focusedField = nil
        Task {
            await authViewModel.signup(email: email, password: password, name: name, modelContext: modelContext)
            if authViewModel.isLoggedIn {
                dismiss()
            }
        }
    }
}

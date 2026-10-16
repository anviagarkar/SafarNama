import Foundation
import Combine
import SwiftData

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentEmail: String? = nil
    @Published var currentName: String? = nil
    @Published var forgotPasswordSuccess: Bool = false
    @Published var resetPasswordSuccess: Bool = false
    @Published var signupSucceededButLoginFailed: Bool = false
    @Published var justSignedUp: Bool = false

    init() {
        if let savedEmail = KeychainHelper.read(forKey: "email"),
           let token = KeychainHelper.read(forKey: "jwt") {
            currentEmail = savedEmail
            isLoggedIn = true
            Task {
                if let profile = try? await AuthService.fetchProfile(token: token) {
                    await MainActor.run { self.currentName = profile.name }
                }
            }
        }
    }

    func signup(email: String, password: String, name: String, modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        signupSucceededButLoginFailed = false

        do {
            try await AuthService.signup(email: email, password: password, name: name)

            do {
                try await loginOrThrow(email: email, password: password, modelContext: modelContext)
                justSignedUp = true
            } catch {
                // Account was created successfully, but auto-login failed (e.g. network blip)
                signupSucceededButLoginFailed = true
                errorMessage = "Account created! Please check your connection and log in."
            }
        } catch {
            errorMessage = "Signup failed. That email may already be in use."
        }

        isLoading = false
    }

    private func loginOrThrow(email: String, password: String, modelContext: ModelContext) async throws {
        let token = try await AuthService.login(email: email, password: password)
        KeychainHelper.save(token, forKey: "jwt")
        KeychainHelper.save(email, forKey: "email")
        currentEmail = email
        isLoggedIn = true

        if let profile = try? await AuthService.fetchProfile(token: token) {
            currentName = profile.name
        }

        try await SyncService.pull(modelContext: modelContext)
    }

    func login(email: String, password: String, modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil

        do {
            try await loginOrThrow(email: email, password: password, modelContext: modelContext)
        } catch AuthError.invalidCredentials {
            errorMessage = "Incorrect email or password."
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

        isLoading = false
    }

    func logout(modelContext: ModelContext) async {
        try? await SyncService.push(modelContext: modelContext)

        KeychainHelper.delete(forKey: "jwt")
        KeychainHelper.delete(forKey: "email")
        isLoggedIn = false
        currentEmail = nil
        currentName = nil

        do {
            try modelContext.delete(model: Country.self)
            try modelContext.save()
        } catch {
            print("Failed to clear local data on logout: \(error)")
        }
    }

    func deleteAccount(modelContext: ModelContext) async -> Bool {
        guard let token = KeychainHelper.read(forKey: "jwt") else { return false }
        do {
            try await AuthService.deleteAccount(token: token)
            await logout(modelContext: modelContext)
            return true
        } catch {
            errorMessage = "Failed to delete account. Please try again."
            return false
        }
    }
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        forgotPasswordSuccess = false

        do {
            try await AuthService.forgotPassword(email: email)
            forgotPasswordSuccess = true
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

        isLoading = false
    }

    func resetPassword(token: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil
        resetPasswordSuccess = false

        do {
            try await AuthService.resetPassword(token: token, newPassword: newPassword)
            resetPasswordSuccess = true
        } catch AuthError.invalidResetCode {
            errorMessage = "That code is invalid or has expired."
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

        isLoading = false
    }
}

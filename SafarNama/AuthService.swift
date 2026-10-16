import Foundation

struct SignupRequest: Codable {
    let email: String
    let password: String
    let name: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct UserProfile: Codable {
    let id: Int
    let email: String
    let name: String?
}
struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let token: String
    let newPassword: String
}

enum AuthError: Error {
    case invalidCredentials
    case invalidResetCode
    case serverError
    case networkError
}

class AuthService {
    static let baseURL = "https://safarnama-backend-71sf.onrender.com"

    static func signup(email: String, password: String, name: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = SignupRequest(email: email, password: password, name: name)
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode != 200 {
            throw AuthError.serverError
        }
    }

    static func login(email: String, password: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode == 401 {
            throw AuthError.invalidCredentials
        }

        if httpResponse.statusCode != 200 {
            throw AuthError.serverError
        }

        guard let token = String(data: data, encoding: .utf8) else {
            throw AuthError.serverError
        }

        return token
    }

    static func fetchProfile(token: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/auth/me") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.serverError
        }

        return try JSONDecoder().decode(UserProfile.self, from: data)
    }

    static func deleteAccount(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/me") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.serverError
        }
    }
    static func forgotPassword(email: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/forgot-password") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ForgotPasswordRequest(email: email)
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode != 200 {
            throw AuthError.serverError
        }
    }

    static func resetPassword(token: String, newPassword: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/reset-password") else {
            throw AuthError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ResetPasswordRequest(token: token, newPassword: newPassword)
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.networkError
        }

        if httpResponse.statusCode == 400 {
            throw AuthError.invalidResetCode
        }

        if httpResponse.statusCode != 200 {
            throw AuthError.serverError
        }
    }
}

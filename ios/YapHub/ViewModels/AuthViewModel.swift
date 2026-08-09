import Foundation
import SwiftUI

@Observable
final class AuthViewModel {
    var isLoggedIn: Bool = false
    var userId: String?
    var username: String = ""
    var displayName: String = ""

    // Login form
    var loginUsername: String = ""
    var loginPassword: String = ""

    // Register form
    var registerUsername: String = ""
    var registerPassword: String = ""
    var registerConfirmPassword: String = ""
    var registerDisplayName: String = ""

    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false

    private let authService = AuthService()

    init() {
        // Restore persisted login state
        let defaults = UserDefaults.standard
        if let savedUserId = defaults.string(forKey: "yh_user_id") {
            self.userId = savedUserId
            self.username = defaults.string(forKey: "yh_username") ?? ""
            self.displayName = defaults.string(forKey: "yh_display_name") ?? ""
            self.isLoggedIn = true
        }
    }

    // MARK: - Login

    func login() async {
        guard !loginUsername.isEmpty, !loginPassword.isEmpty else {
            setError("Please enter both username and password")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.login(
                username: loginUsername,
                password: loginPassword
            )
            persistLogin(userId: response.userId, username: loginUsername, displayName: "")
            clearLoginForm()
        } catch let error as APIError {
            setError(error.localizedDescription)
        } catch {
            setError("Login failed. Please try again.")
        }

        isLoading = false
    }

    // MARK: - Register

    var registerPasswordsMatch: Bool {
        registerPassword == registerConfirmPassword
    }

    var registerFormValid: Bool {
        !registerUsername.isEmpty &&
        !registerDisplayName.isEmpty &&
        !registerPassword.isEmpty &&
        registerPasswordsMatch &&
        registerPassword.count >= 4
    }

    func register() async {
        guard registerFormValid else {
            if !registerPasswordsMatch {
                setError("Passwords do not match")
            } else {
                setError("Please fill out all fields. Password must be at least 4 characters.")
            }
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.register(
                username: registerUsername,
                password: registerPassword,
                displayName: registerDisplayName
            )
            persistLogin(userId: response.userId, username: registerUsername, displayName: registerDisplayName)
            clearRegisterForm()
        } catch let error as APIError {
            setError(error.localizedDescription)
        } catch {
            setError("Registration failed. Please try again.")
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() async {
        isLoading = true
        _ = try? await authService.logout()
        clearPersistedLogin()
        isLoading = false
    }

    // MARK: - Persistence

    private func persistLogin(userId: String, username: String, displayName: String) {
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: "yh_user_id")
        defaults.set(username, forKey: "yh_username")
        defaults.set(displayName, forKey: "yh_display_name")

        self.userId = userId
        self.username = username
        self.displayName = displayName
        self.isLoggedIn = true
    }

    private func clearPersistedLogin() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "yh_user_id")
        defaults.removeObject(forKey: "yh_username")
        defaults.removeObject(forKey: "yh_display_name")

        // Clear cookies
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }

        self.userId = nil
        self.username = ""
        self.displayName = ""
        self.isLoggedIn = false
    }

    // MARK: - Helpers

    private func setError(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func clearLoginForm() {
        loginUsername = ""
        loginPassword = ""
    }

    private func clearRegisterForm() {
        registerUsername = ""
        registerPassword = ""
        registerConfirmPassword = ""
        registerDisplayName = ""
    }
}

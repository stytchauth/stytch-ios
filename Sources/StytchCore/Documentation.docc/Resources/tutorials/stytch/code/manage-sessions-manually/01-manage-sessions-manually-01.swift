final class AuthenticationClient {
    func authCheck() async throws -> AuthResponse {
        try await api.performAuthCheck()
    }
}

import StytchCore

final class AuthenticationClient {
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task {
                do {
                    let response = try await authCheck()
                } catch {}
            }
        }
    }

    func authCheck() async throws -> AuthResponse {
        try await api.performAuthCheck()
    }
}

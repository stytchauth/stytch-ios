extension Session.Storage {
    enum KeychainStorageClient {
        static func onUpdate(tokens: [Session.Token]) {
            tokens.forEach { token in
                do {
                    try KeychainClient.set(token.value, for: .init(kind: .token, name: token.name))
                } catch {
                    print(error)
                }
            }
        }

        static func storedSessionTokens() -> [Session.Token] {
            Session.Token.Kind.allCases.compactMap { kind in
                do {
                    guard let value = try KeychainClient.get(.init(kind: .token, name: kind.name)) else { return nil }

                    switch kind {
                    case .opaque:
                        return .opaque(value)
                    case .jwt:
                        return .jwt(value)
                    }
                } catch {
                    print(error)
                    return nil
                }
            }
        }
    }
}


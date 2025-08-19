import Foundation

public protocol CryptoWalletsProtocol {
    func authenticateStart(parameters: StytchClient.CryptoWallets.AuthenticateStartParameters) async throws -> StytchClient.CryptoWallets.AuthenticateStartResponse
    func authenticate(parameters: StytchClient.CryptoWallets.AuthenticateParameters) async throws -> StytchClient.CryptoWallets.CryptoAuthenticateResponse
}

public extension StytchClient {
    /// The SDK provides methods that can be used to authenticate a user via their crypto wallet.
    struct CryptoWallets: CryptoWalletsProtocol {
        let router: NetworkingRouter<CryptoWalletsRoute>

        @Dependency(\.sessionManager) private var sessionManager

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's Crypto wallet [authenticate_start](https://stytch.com/docs/api/crypto-wallet-authenticate-start) endpoint. Call this method to load the challenge data. Pass this challenge to your user's wallet for signing.
        public func authenticateStart(parameters: AuthenticateStartParameters) async throws -> AuthenticateStartResponse {
            let route: CryptoWalletsRoute = sessionManager.hasValidSessionToken ? .authenticateStartSecondary : .authenticateStartPrimary
            return try await router.post(to: route, parameters: parameters)
        }

        // sourcery: AsyncVariants, (NOTE: - must use /// doc comment styling)
        /// Wraps Stytch's Crypto wallet [authenticate](https://stytch.com/docs/api/crypto-wallet-authenticate) endpoint. Call this method after the user signs the challenge to validate the signature.
        public func authenticate(parameters: AuthenticateParameters) async throws -> CryptoAuthenticateResponse {
            let authenticateResponse: CryptoAuthenticateResponse = try await router.post(to: .authenticate, parameters: parameters, useDFPPA: true)
            sessionManager.consumerLastAuthMethodUsed = .crypto
            return authenticateResponse
        }
    }
}

public extension StytchClient.CryptoWallets {
    /// The type of crypto wallet. Currently `ethereum` and `solana` are supported. Wallets for any EVM-compatible chains (such as Polygon or BSC) are also supported and are grouped under the `ethereum` type.
    enum WalletType: String, Codable, Sendable {
        case ethereum
        case solana
    }

    /// The dedicated parameters type for crypto wallets `authenticateStart` calls.
    struct AuthenticateStartParameters: Encodable, Sendable {
        let cryptoWalletType: WalletType
        let cryptoWalletAddress: String

        /// - Parameters:
        ///   - cryptoWalletType: The type of wallet to authenticate.
        ///   - cryptoWalletAddress: The crypto wallet address to authenticate.
        public init(cryptoWalletType: WalletType, cryptoWalletAddress: String) {
            self.cryptoWalletType = cryptoWalletType
            self.cryptoWalletAddress = cryptoWalletAddress
        }
    }

    /// The dedicated parameters type for crypto wallets `authenticate` calls.
    struct AuthenticateParameters: Encodable, Sendable {
        let cryptoWalletType: WalletType
        let cryptoWalletAddress: String
        let signature: String

        /// - Parameters:
        ///   - cryptoWalletType: The type of wallet to authenticate.
        ///   - cryptoWalletAddress: The crypto wallet address to authenticate.
        ///   - signature: The signature from the message challenge.
        public init(cryptoWalletType: WalletType, cryptoWalletAddress: String, signature: String) {
            self.cryptoWalletType = cryptoWalletType
            self.cryptoWalletAddress = cryptoWalletAddress
            self.signature = signature
        }
    }
}

public extension StytchClient.CryptoWallets {
    /// The concrete response type for crypto wallets `authenticateStart` calls.
    typealias AuthenticateStartResponse = Response<CryptoWalletsAuthenticateResponseData>

    /// The underlying data for crypto wallets `authenticateStart` calls.
    struct CryptoWalletsAuthenticateResponseData: Codable, Sendable {
        /// A challenge string to be signed by the wallet in order to prove ownership.
        public let challenge: String

        public init(challenge: String) {
            self.challenge = challenge
        }
    }

    typealias CryptoAuthenticateResponse = Response<CryptoAuthenticateResponseData>
    struct CryptoAuthenticateResponseData: Codable, Sendable, AuthenticateResponseDataType {
        public let user: User
        public let session: Session
        public let sessionToken: String
        public let sessionJwt: String
        public let userDevice: SDKDeviceHistory?
    }
}

public extension StytchClient {
    /// The interface for interacting with crypto wallet products.
    static var cryptoWallets: CryptoWallets { .init(router: router.scopedRouter { $0.cryptoWallets }) }
}

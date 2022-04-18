import Foundation

public struct StytchClient {
    static var instance: StytchClient = .init()

    var configuration: Configuration?

    private init() {}

    public static func configure(publicToken: String, hostDomain: URL) {
        instance.configuration = .init(hostDomain: hostDomain, publicToken: publicToken)
        Current.networkingClient.headerProvider = {
            guard let configuration = instance.configuration else { return [:] }

            let sessionToken = Current.sessionStorage.sessionToken ?? configuration.publicToken
            let authToken = "\(configuration.publicToken):\(sessionToken)".base64Encoded

            return [
                "Content-Type": "application/json",
//                "User-Agent": "Stytch iOS SDK v0.0.1", // TODO: - figure out why this errors
                "User-Agent": "stytchios/0.0.1",
                "Authorization": "Basic \(authToken)",
                "X-SDK-Parent-Host": hostDomain.absoluteString,
            ]
        }
    }
}

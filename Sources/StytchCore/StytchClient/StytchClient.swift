import Foundation

public struct StytchClient {
    static var instance: StytchClient = .init()

    var configuration: Configuration?

    private init() {}

    public static func configure(publicToken: String, hostUrl: URL) {
        instance.configuration = .init(hostUrl: hostUrl, publicToken: publicToken)
        Current.networkingClient.headerProvider = {
            guard let configuration = instance.configuration else { return [:] }

            let sessionToken = /* Current.sessionStorage.sessionToken ?? */ configuration.publicToken
            let authToken = "\(configuration.publicToken):\(sessionToken)".base64Encoded

            return [
                "Content-Type": "application/json",
                //                "User-Agent": "Stytch iOS SDK v0.0.1", // TODO: - figure out why this errors
                "User-Agent": "stytchios/0.0.1",
                "Authorization": "Basic \(authToken)",
                "X-SDK-Parent-Host": hostUrl.absoluteString,
            ]
        }
    }

    // sourcery: AsyncVariants
    public static func handle(url: URL, completion: @escaping Completion<DeeplinkHandledStatus>) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems,
            let typeQuery = queryItems.first(where: { $0.name == "type" }),
            let tokenQuery = queryItems.first(where: { $0.name == "token" }), let token = tokenQuery.value
        else {
            completion(.success(.right(url)))
            return
        }

        switch typeQuery.value {
        case "em":
            // TODO: pass session duration as function parameter
            magicLinks.authenticate(parameters: .init(token: token, sessionDuration: .init(rawValue: 30))) { result in
                completion(result.map { .left(($0, url)) })
            }
        default:
            completion(.failure(StytchError(message: "Unrecognized deeplink type")))
        }
    }
}

public extension StytchClient {
    typealias DeeplinkHandledStatus = Either<(AuthenticateResponse, URL), URL>
}

public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

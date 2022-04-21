import Foundation

/**
 The entrypoint for all Stytch-related interaction. Supported Stytch products are organized into interface structs which are
 exposed as static variables on the client, e.g. `StytchClient.magicLinks.email`.
 To utilize the ``StytchClient``, you must first configure it using the
 ``configure(publicToken:hostUrl:)`` function.
 **Async Options**: Asynchronous function calls for Stytch products are available via various
 mechanisms (async/await, Combine, callbacks) so you can use whatever best suits your needs.
 ``` swift
 // In your AppDelegate or SwiftUI App file
 import StytchCore
 ...
 StytchClient.configure(publicToken: stytchToken, hostUrl: appUrl)
 // In another file, when you later want to send an email magic link
 let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: emailMagicLinkParams)
 // Back in your AppDelegate/App file
 .onOpenUrl { url in
     switch try await StytchClient.handle(url: url) {
     case let .a(sessionResponse, url):
         // Utilize the sessionResponse and url as needed for any additional processing, cookies will automatically be stored for your convenience
     case let .b(url):
         // The url was not processed
     }
 }
 ```
 */
public struct StytchClient {
    static var instance: StytchClient = .init()

    var configuration: Configuration?

    private init() {}

    /**
     Configures the `StytchClient`, setting the `publicToken` and `hostUrl`.
     while the `hostUrl`
     - Parameters:
     - publicToken: Available via the Stytch dashboard in the `API keys` section
     - hostUrl: Generally this is your backend's base url, where your apple-app-site-association file is hosted. This is an https url which verifies your app is allowed to communicate with Stytch.
     This **must be set** as an `Authorized Domain` in the Stytch dashboard SDK configuration.
     */
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
    /**
     This function is provided as a simple convenience handler to be used in your AppDelegate or
    /// SwiftUI App file upon receiving a deeplink URL, e.g. `.onOpenURL {}`.
    /// If Stytch is able to handle the URL and log the user in, a ``SessionResponseType`` will be returned to you asynchronously, with a `sessionDuration` of the length requested here. Regardless of
    /// whether Stytch is able to handle the URL, it will be passed back to you for any further processing needs.
    /// - Parameters:
    ///   - url: A `URL` passed to your application as a deeplink.
    ///   - sessionDuration: The desired session duration in ``Minutes``. Defaults to 30.
    ///   - completion: A ``DeeplinkHandledStatus`` will be returned asynchronously.
     */
    public static func handle(
        url: URL,
        sessionDuration: Minutes = 30,
        completion: @escaping Completion<DeeplinkHandledStatus>
    ) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let typeQuery = queryItems.first(where: { $0.name == "type" }),
            let tokenQuery = queryItems.first(where: { $0.name == "token" }), let token = tokenQuery.value
        else {
            completion(.success(.notHandled(url)))
            return
        }

        switch typeQuery.value {
        case "em":
            magicLinks.authenticate(parameters: .init(token: token, sessionDuration: sessionDuration)) { result in
                completion(result.map { .handled(($0, url)) })
            }
        default:
            completion(.failure(StytchError(message: "Unrecognized deeplink type")))
        }
    }
}

public extension StytchClient {
    /**
     Represents whether a deeplink was able to be handled, containing the original URL for further processing and
     Session-related information when appropriate.
     */
    typealias DeeplinkHandledStatus = HandledStatus<(SessionResponseType, URL), URL>

    /**
     A simple, generic type designed to explictly describe an item's handled status from a given handler.
     */
    enum HandledStatus<Handled, NotHandled> {
        /// The handler was successfully able to handle the given item.
        case handled(Handled)
        /// The handler was unable to handle the given item.
        case notHandled(NotHandled)
    }
}


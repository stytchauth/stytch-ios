import AuthenticationServices
import Foundation

#if !os(watchOS)
/// The dedicated parameters type for the ``start(parameters:)-p3l8`` call.
@available(tvOS 16.0, *)
public protocol WebAuthenticationSessionClientConfiguration {
    var clientType: ClientType { get }

    #if !os(tvOS)
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get }
    #endif

    func startUrl(_ providerName: String) throws -> URL
    func callbackUrlScheme() throws -> String
}

@available(tvOS 16.0, *)
extension WebAuthenticationSessionClientConfiguration {
    func webAuthenticationSessionClientParameters(providerName: String) throws -> WebAuthenticationSessionClient.Parameters {
        #if !os(tvOS)
        let webAuthenticationSessionClientParameters: WebAuthenticationSessionClient.Parameters = .init(
            url: try startUrl(providerName),
            callbackUrlScheme: try callbackUrlScheme(),
            presentationContextProvider: presentationContextProvider ?? WebAuthenticationSessionClient.DefaultPresentationProvider(),
            clientType: clientType
        )
        return webAuthenticationSessionClientParameters
        #else
        let webAuthenticationSessionClientParameters: WebAuthenticationSessionClient.Parameters = .init(
            url: try startUrl(providerName),
            callbackUrlScheme: try callbackUrlScheme(),
            clientType: clientType
        )
        return webAuthenticationSessionClientParameters
        #endif
    }
}
#endif

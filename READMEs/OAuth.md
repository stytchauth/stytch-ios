# OAuth
The Stytch iOS SDK supports two types of OAuth flows: Third Party (redirect) and Native (Sign In With Apple), both of which can be configured in the Stytch Dashboard.

The configuration necessary for each type of flow is different, so read on to see how to set each up.

Third-party/Redirect OAuth is the OAuth you may be most familiar with on the web: You click a button, are redirected to the selected IdP, login, and are redirected back to the original webpage. The same concept applies with the Stytch iOS SDK and redirects are handled in a webview.

To see all of the currently supported providers, check the cases of the `Provider` enum in [OAuth+ThirdParty](../stytch-ios/Sources/StytchCore/StytchClient/OAuth/OAuth+ThirdParty.swift).

## Third Party
For this example, we're going to use a redirect path of `my-app://login` and `my-app://signup`, so make sure to add that as a valid redirect URL for the `Login` and `Signup` types in your Stytch Dashboard's [Redirect URL settings](stytch.com/dashboard/redirect-urls). You will also need to configure an [OAuth provider](https://stytch.com/dashboard/oauth). In this example, we are using Google.

```swift
import StytchCore

let configuraiton = StytchClient.OAuth.ThirdParty.WebAuthenticationConfiguration(
    loginRedirectUrl: URL(string: "my-app://login"),
    signupRedirectUrl: URL(string: "my-app://signup"),
    customScopes: nil,
    providerParams: nil
)

Task {
    do {
        let (token, url) = try await StytchClient.oauth.google.start(configuration: configuraiton)
        let parameters = StytchClient.OAuth.AuthenticateParameters(token: token)
        let response = try await StytchClient.oauth.authenticate(parameters: parameters)
        print(response.session)
    } catch {
        print(error.errorInfo)
    }
}
```

## Native (Sign In With Apple)

Native OAuth with Stytch is simpler than other OAuth providers because the entire flow is handled by a single call. With Sign In With Apple, you only need to call `StytchClient.oauth.apple.start()`.

**Two step flow for other providers:**  
Call `start()` to launch the provider UI and receive an intermediate token.  
Call `authenticate()` with that token to complete sign in.

With native Sign In With Apple, you do not call `authenticate()` yourself. The implementation performs the token exchange and completes authentication when you call `start()`.
This method presents the native Sign In With Apple UI, handles user consent, performs the token exchange, and returns a Stytch session. 
```swift
import StytchCore

Task {
    do {
        let response = try await StytchClient.oauth.apple.start(parameters: .init())
        print(response.session)
    } catch {
        print(error.errorInfo)
    }
}
```

### Configuring Your App for Sign In With Apple

Before using `StytchClient.oauth.apple`, your Xcode project and Apple Developer account must be configured for Sign In With Apple. The following official Apple resources provide detailed guidance:

[Getting Started – Sign In With Apple](https://developer.apple.com/sign-in-with-apple/get-started/)  
Overview of the Sign In With Apple flow and setup process.

[Configuring your environment for Sign In With Apple](https://developer.apple.com/documentation/signinwithapple/configuring-your-environment-for-sign-in-with-apple)  
Step by step instructions for setting up your environment, including creating an App ID, Service ID, and private key.

[Create a Sign In With Apple private key](https://developer.apple.com/help/account/configure-app-capabilities/create-a-sign-in-with-apple-private-key/)  
Instructions for generating and linking the private key used for secure token exchange.

[Configuring Sign In With Apple support in Xcode](https://developer.apple.com/documentation/xcode/configuring-sign-in-with-apple)  
Guide for enabling the Sign In With Apple capability in your Xcode project.

## Further Reading
For more information on the Stytch OAuth product, consult our [OAuth guide](https://stytch.com/docs/guides/oauth/idp-overview).

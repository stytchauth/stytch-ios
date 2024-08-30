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
Native OAuth is a little bit different from, and quite a bit simpler than, Third Party OAuth, in which we use [Sign In With Apple](https://developer.apple.com/sign-in-with-apple/get-started/) to launch and authenticate an "OAuth ID Token" flow.
```swift
import StytchCore

Task {
    do {
        let response = try await StytchClient.oauth.apple.start(parameters: .init())
        print(response.userCreated)
    } catch {
        print(error.errorInfo)
    }
}
```

## Further Reading
For more information on the Stytch OAuth product, consult our [OAuth guide](https://stytch.com/docs/guides/oauth/idp-overview).

# Email Magic Links
Email magic links are a secure and user-friendly way to log in to an application without needing to enter a password. There are four steps to the email magic link flow:

1. **Login Request** - The user initiates a login request in your app by entering their email address.
2. **Email with Magic Link:** - Stytch generates a unique, time-sensitive link, and sends it to the user.
3. **Clicking the Link:** - The user opens the email and clicks on the magic link, which redirects into your application
4. **Verification** - Your application extracts a token from the redirect link and authenticates it with Stytch.

## Types of Magic Links
The Stytch iOS SDK offers two methods for email magic links:
1. **loginOrCreate** - This method will log a user in, if one exists, or create a user, if none exists. This is a great option for a flow where you allow a user to login or signup from the same screen.
2. **send** - This method will only send a magic link to a user if they already exist, and can be used to restrict access to existing users, perform step-up authorization, or any other flow where you only want to authenticate an existing user.

While the initialization methods are different, and they behave differently when the request is received on Stytch's servers, the implementation of the email magic link flow in your application is the same.

## Implementation
The first thing you need to do is configure your application for deeplinks, as they are the fundamental aspect of the email magic link flow. For more information on configuring deeplinks, read our [Deeplinks Tutorial](./Deeplinks.md).

Next, call the appropriate method with any optional parameters you desire:
```swift
import StytchCore

// Create the parameters
let parameters = StytchClient.MagicLinks.Email.Parameters.init(
    email: "user@email.com",
    // The following parameters are all optional
    loginMagicLinkUrl: URL(string: "my-app://stytch-auth/login"), // The URL to be directed to on login. Will use your default, if not provided
    loginExpiration: .defaultSessionDuration, // the duration after which the login url should expire
    loginTemplateId: "my-login-template", // a custom template for login emails, if you've configured one
    signupMagicLinkUrl: URL(string: "my-app://stytch-auth/signup"),  // The URL to be directed to on user creation. It is ignored on send requests. Will use your default, if not provided
    signupExpiration: .defaultSessionDuration, // the duration after which the login url should expire
    signupTemplateId: "my-signup-template" // a custom template for signup emails, if you've configured one. It is ignored on send requests
)

func loginOrCreate(parameters: StytchClient.MagicLinks.Email.Parameters) {
    Task {
        do {
            // Requests an email magic link for a user to log in or create an account depending on the presence and/or status of an existing account.
            let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)
            print(response)
        } catch {
            print(error.errorInfo)
        }
    }
}

func send(parameters: StytchClient.MagicLinks.Email.Parameters) {
    Task {
        do {
            // Requests an email magic link for an existing user to log in or attach the included email factor to their current account.
            let response = try await StytchClient.magicLinks.email.send(parameters: parameters)
            print(response)
        } catch {
            print(error.errorInfo)
        }
    }
}
```

Lastly, once you receive the deeplink it will be automatically authenticated using the `try await StytchClient.handle(url: url, sessionDurationMinutes: 5)` method.

## PKCE
PKCE (Pronounced "pixie") stands for Proof Key for Code Exchange, and is a method of ensuring that an authentication flow that starts on one device is completed on the same device, to avoid an authorization code interception attack. While PKCE is optional when integrating with our backend SDKs, it is mandatory when using our mobile SDKs. When using the Stytch iOS SDK, the management of the PKCE flow is automatic; it will automatically create PKCE code pairs and use and delete them as appropriate.

There are some instances where you may need to begin a flow on your mobile application, which will mark the flow as requiring PKCE, but complete it somewhere else (say, your backend). For these instances, we provide a method of retrieving the generated PKCE code pair so that you can use it as necessary.

```swift
import StytchCore

// launch a PKCE-enabled flow
let parameters = StytchClient.MagicLinks.Email.Parameters.init(email: "user@email.com")
let response = try await StytchClient.magicLinks.email.loginOrCreate(parameters: parameters)

// retrieve the PKCE code pair that was generated
let pkceCodePair: PKCECodePair? = StytchClient.getPKCECodePair()

// pass the code pair to your backend
...
```

## Further Reading
For more information on Email Magic Links, check out the [guide](https://stytch.com/docs/guides/magic-links/email-magic-links/api).

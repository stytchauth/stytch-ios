#  ``StytchCore``

Provides native access to the Stytch SDK methods for ultimate flexibility.

The Swift SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to [Stytch](https://stytch.com).

## Topics

### Using Stytch

 You'll interact with Stytch via the ``StytchClient``. Supported Stytch products are accessed via nested static variables on the client, e.g. `StytchClient.magicLinks.email`, where you can access the underlying methods, e.g. `StytchClient.magicLinks.email.loginOrCreate(parameters:completion:)`

There are a number of authentication products currently supported by the SDK, with additional functionality coming in the near future! The currently supported products are:

Product | Methods | Delivery mechanisms
--- | --- | ---
``StytchClient/MagicLinks-swift.struct`` | ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/loginOrCreate(parameters:completion:)``, ``StytchClient/MagicLinks-swift.struct/authenticate(parameters:completion:)`` | Email 
``StytchClient/Passwords-swift.struct`` | ``StytchClient/Passwords-swift.struct/create(parameters:)-3gtlz``, ``StytchClient/Passwords-swift.struct/authenticate(parameters:)-9xbzg``, ``StytchClient/Passwords-swift.struct/``, ``StytchClient/Passwords-swift.struct/resetByEmail(parameters:)-79mm8``, ``StytchClient/Passwords-swift.struct/strengthCheck(parameters:)-1d3s7`` | N/A
``StytchClient/OneTimePasscodes`` | ``StytchClient/OneTimePasscodes/loginOrCreate(parameters:completion:)``, ``StytchClient/OneTimePasscodes/authenticate(parameters:completion:)`` | SMS, WhatsApp, Email
``StytchClient/Sessions-swift.struct`` | ``StytchClient/Sessions-swift.struct/revoke(completion:)``, ``StytchClient/Sessions-swift.struct/authenticate(parameters:completion:)`` | N/A

**Async Options**: Async functions are available via various mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.

#### Configuration

 Prior to using any authentication methods, you must configure the StytchClient via one of two techniques: 1) Automatically, by including a `StytchConfiguration.plist` file in your main app bundle ([example](https://github.com/stytchauth/stytch-swift/blob/main/StytchDemo/Shared/StytchConfiguration.plist)) or 2) Programmatically using the static ``StytchClient/configure(publicToken:hostUrl:)`` function.
 
 #### Usage

With just a few lines of code, you can easily authenticate your users and get back to focusing on the core of your product.
 
``` swift
import StytchCore
// When a user has entered their email and requests a magic link
_ = try await StytchClient.magicLinks.email.loginOrCreate(
    parameters: .init(email: userEmail)
)
// Handling the deeplink in your SwiftUI App file (similar for AppDelegate)
YourContentView().onOpenUrl { url in
    switch try await StytchClient.handle(url: url) {
        // Your handling code
    }
}
```

- ``StytchClient``
- ``Session``
- ``User``

### Response Types

- ``AuthenticateResponse``
- ``BasicResponse``
- ``Response``
- ``AuthenticateResponseData``

### Error Types
- ``StytchError``

### Additional Types

- ``Completion``
- ``Minutes``
- ``EmptyCodable``

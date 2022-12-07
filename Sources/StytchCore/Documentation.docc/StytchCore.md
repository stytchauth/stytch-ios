#  ``StytchCore``

Provides native access to the Stytch SDK methods for ultimate flexibility.

The Swift SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to [Stytch](https://stytch.com).

## Topics

### Using Stytch

 You'll interact with Stytch via the ``StytchClient``. Supported Stytch products are accessed via nested static variables on the client, e.g. `StytchClient.magicLinks.email`, where you can access the underlying methods, e.g. StytchClient.magicLinks.email.loginOrCreate(parameters:)`

There are a number of authentication products currently supported by the SDK, with additional functionality coming in the near future! The currently supported products are:

Product | Methods | Delivery mechanisms
--- | --- | ---
``StytchClient/MagicLinks-swift.struct`` | ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/loginOrCreate(parameters:)-7ic79``, ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/send(parameters:)-9vd2t``, ``StytchClient/MagicLinks-swift.struct/authenticate(parameters:)-4aa9c`` | Email 
``StytchClient/Passwords-swift.struct`` | ``StytchClient/Passwords-swift.struct/create(parameters:)-3gtlz``, ``StytchClient/Passwords-swift.struct/authenticate(parameters:)-8qxx5``, ``StytchClient/Passwords-swift.struct/resetByEmailStart(parameters:)-4xpf9``, ``StytchClient/Passwords-swift.struct/resetByEmail(parameters:)-353x1``, ``StytchClient/Passwords-swift.struct/strengthCheck(parameters:)-1d3s7`` | N/A
``StytchClient/OneTimePasscodes`` | ``StytchClient/OneTimePasscodes/loginOrCreate(parameters:)-8i9gy``, ``StytchClient/OneTimePasscodes/send(parameters:)-6f247``, ``StytchClient/OneTimePasscodes/authenticate(parameters:)-151as`` | SMS, WhatsApp, Email
``StytchClient/Biometrics-swift.struct`` | ``StytchClient/Biometrics-swift.struct/register(parameters:)-812fz``, ``StytchClient/Biometrics-swift.struct/authenticate(parameters:)-7b3rx``, ``StytchClient/Biometrics-swift.struct/registrationAvailable``, ``StytchClient/Biometrics-swift.struct/removeRegistration()`` | N/A
``StytchClient/OAuth-swift.struct`` | ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-172ak``, ``StytchClient/OAuth-swift.struct/Apple-swift.struct/start(parameters:)-858tw``, ``StytchClient/OAuth-swift.struct/ThirdParty/start(parameters:)`` | N/A
``StytchClient/Sessions-swift.struct`` | ``StytchClient/Sessions-swift.struct/revoke()-4jc0p``, ``StytchClient/Sessions-swift.struct/authenticate(parameters:)-41u13`` | N/A
``StytchClient/UserManagement`` | ``StytchClient/UserManagement/syncUser``, ``StytchClient/UserManagement/get()-57gt5``, ``StytchClient/UserManagement/deleteFactor(_:)-5nh6h`` | N/A

**Async Options**: Async functions are available via various mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.

#### Configuration

 Prior to using any authentication methods, you must configure the StytchClient via one of two techniques: 1) Automatically, by including a `StytchConfiguration.plist` file in your main app bundle ([example](https://github.com/stytchauth/stytch-swift/blob/main/StytchDemo/Client/Shared/StytchConfiguration.plist)) or 2) Programmatically using the static ``StytchClient/configure(publicToken:hostUrl:)`` function.
 
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

- ``AuthenticateResponseType``
- ``AuthenticateResponseDataType``
- ``BasicResponseType``
- ``BasicResponse``
- ``Response``

### Error Types
- ``StytchError``

### Additional Types

- ``Completion``
- ``Minutes``
- ``EmptyCodable``


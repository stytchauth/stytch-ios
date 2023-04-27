#  ``StytchCore``

Provides native access to the Stytch SDK methods for ultimate flexibility.

The Swift SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to [Stytch](https://stytch.com).

_To see in-depth examples of basic, intermediate, and advanced usage of the Stytch SDK, check out our <doc:stytch>!_

## Using Stytch

You'll interact with Stytch via the ``StytchClient`` (consumer apps) or ``StytchB2BClient`` (B2B apps), depending on your use case. Supported Stytch products are accessed via nested static variables on the client, e.g. `StytchClient.magicLinks.email`, where you can access the underlying methods, e.g. `StytchClient.magicLinks.email.loginOrCreate(parameters:)`.

There are a number of authentication products currently supported by the SDK, with additional functionality coming in the near future! The currently supported products are:

### Consumer apps

Product | Methods | Delivery mechanisms
--- | --- | ---
``StytchClient/MagicLinks-swift.struct`` | ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/loginOrCreate(parameters:)-9n8i5``, ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/send(parameters:)-2i2l1``, ``StytchClient/MagicLinks-swift.struct/authenticate(parameters:)-27v6k`` | Email 
``StytchClient/Passwords-swift.struct`` | ``StytchClient/Passwords-swift.struct/create(parameters:)-3gtlz``, ``StytchClient/Passwords-swift.struct/authenticate(parameters:)-9xbzg``, ``StytchClient/Passwords-swift.struct/resetByEmailStart(parameters:)-4xpf9``, ``StytchClient/Passwords-swift.struct/resetByEmail(parameters:)-79mm8``, ``StytchClient/Passwords-swift.struct/strengthCheck(parameters:)-1d3s7`` | Email (resets)
``StytchClient/OTP`` | ``StytchClient/OTP/loginOrCreate(parameters:)-c61b``, ``StytchClient/OTP/send(parameters:)-3xcc9``, ``StytchClient/OTP/authenticate(parameters:)-5ums0`` | SMS, WhatsApp, Email
``StytchClient/Biometrics-swift.struct`` | ``StytchClient/Biometrics-swift.struct/register(parameters:)-m8w7``, ``StytchClient/Biometrics-swift.struct/authenticate(parameters:)-8ycmb``, ``StytchClient/Biometrics-swift.struct/registrationAvailable``, ``StytchClient/Biometrics-swift.struct/removeRegistration()-7a8j9`` | N/A
``StytchClient/OAuth-swift.struct`` | ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd``, ``StytchClient/OAuth-swift.struct/Apple-swift.struct/start(parameters:)-5rxqg``, ``StytchClient/OAuth-swift.struct/ThirdParty/start(parameters:)-239i4``, ``StytchClient/OAuth-swift.struct/ThirdParty/start(parameters:)-p3l8`` | N/A
``StytchClient/TOTP`` | ``StytchClient/TOTP/create(parameters:)-437r4``, ``StytchClient/TOTP/authenticate(parameters:)-2ck6w``, ``StytchClient/TOTP/recoveryCodes()-mbxc``, ``StytchClient/TOTP/recover(parameters:)-9swfk`` | N/A
``Sessions`` | ``Sessions/revoke(parameters:)-7lw27``, ``Sessions/authenticate(parameters:)-7gegg`` | N/A
``StytchClient/UserManagement`` | ``StytchClient/UserManagement/getSync()``, ``StytchClient/UserManagement/get()-57gt5``, ``StytchClient/UserManagement/deleteFactor(_:)-5nh6h`` | N/A

### B2B apps

Product | Methods | Delivery mechanisms
--- | --- | ---
``StytchB2BClient/MagicLinks-swift.struct`` | ``StytchB2BClient/MagicLinks-swift.struct/Email-swift.struct/loginOrSignup(parameters:)-6rrup``, ``StytchB2BClient/MagicLinks-swift.struct/authenticate(parameters:)-9bkrj``, ``StytchB2BClient/MagicLinks-swift.struct/Email-swift.struct/discoverySend(parameters:)-1opgc``, ``StytchB2BClient/MagicLinks-swift.struct/discoveryAuthenticate(parameters:)-4vo9v`` | Email
``StytchB2BClient/Discovery-swift.struct`` | ``StytchB2BClient/Discovery-swift.struct/createOrganization(parameters:)-7hypb``, ``StytchB2BClient/Discovery-swift.struct/listOrganizations(parameters:)-4yarj``, ``StytchB2BClient/Discovery-swift.struct/exchangeIntermediateSession(parameters:)-8uvs8`` | N/A
``StytchB2BClient/SSO-swift.struct`` | ``StytchB2BClient/SSO-swift.struct/start(parameters:)-6ik51``, ``StytchB2BClient/SSO-swift.struct/authenticate(parameters:)-1ncp1`` | N/A
``Sessions`` | ``Sessions/revoke(parameters:)-7lw27``, ``Sessions/authenticate(parameters:)-7gegg`` | N/A
``StytchB2BClient/Members`` | ``StytchB2BClient/Members/getSync()``, ``StytchB2BClient/Members/get()-7fdhf`` | N/A
``StytchB2BClient/Organizations`` | ``StytchB2BClient/Organizations/getSync()``, ``StytchB2BClient/Organizations/get()-2esfw`` | N/A

### Async Options

Async functions are available via various mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.

### Configuration

 Prior to using any authentication methods, you must configure the StytchClient/StytchB2BClient via one of two techniques:
1. Programmatically using the static ``StytchClient/configure(publicToken:hostUrl:)`` (consumer) or ``StytchB2BClient/configure(publicToken:hostUrl:)`` (B2B) functions.
1. Automatically, by including a `StytchConfiguration.plist` file in your main app bundle ([example](https://github.com/stytchauth/stytch-swift/blob/main/StytchDemo/Client/Shared/StytchConfiguration.plist))
 
### Usage

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

## Topics

### Consumer

- ``StytchClient``
- ``Session``
- ``User``

### B2B

- ``StytchB2BClient``
- ``Organization``
- ``MemberSession``
- ``Member``

### Sessions

- ``Sessions``
- ``SessionToken``

### Authenticate Response Types
- ``AuthenticateResponse``
- ``AuthenticateResponseType``
- ``AuthenticateResponseDataType``
- ``AuthenticateResponseData``
- ``B2BAuthenticateResponse``
- ``B2BAuthenticateResponseType``
- ``B2BAuthenticateResponseDataType``
- ``B2BAuthenticateResponseData``

### Generic Response Types

- ``BasicResponseType``
- ``BasicResponse``
- ``Response``

### Error Types
- ``StytchError``

### Deeplink Types

- ``DeeplinkHandledStatus``

### Additional Types

- ``AuthenticationFactor``
- ``SSORegistration``
- ``Identifier``
- ``Completion``
- ``Minutes``
- ``EmptyCodable``
- ``JSON``
- ``Union``
- ``UserResponse``

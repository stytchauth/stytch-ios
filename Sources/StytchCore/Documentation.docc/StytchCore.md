#  ``StytchCore``

Provides native access to the Stytch SDK methods for ultimate flexibility.

The Swift SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to Stytch.

## Topics

### Using Stytch

 You'll interact with Stytch via the ``StytchClient``. Supported Stytch products are organized into interface structs — exposed as static variables on the client, e.g. StytchClient.magicLinks.email. These contain the underlying methods such as: `StytchClient.magicLinks.email.loginOrCreate(parameters:)` // TODO: - update this
 
 Prior to using any authentication methods, you must first configure the ``StytchClient`` using the static `configure(publicToken:hostUrl:)` function. After this, the client is ready for use.
 
 **Async Options**: Async functions are available via various
 mechanisms (Async/Await, Combine, callbacks) so you can use whatever best suits your needs.
 
 #### Example
 
``` swift
// When a user has entered their email and requests a magic link
let response = try await StytchClient.magicLinks.email.loginOrCreate(
    parameters: emailMagicLinkParams
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

- ``SessionResponseType``
- ``AuthenticateResponse``
- ``BasicResponse``
- ``Response``
- ``AuthenticateResponseData

### Error Types
- ``StytchStructuredError``
- ``StytchGenericError``

### Additional Types

- ``Completion``
- ``Minutes``
- ``MinutesTag``
- ``EmptyCodable``

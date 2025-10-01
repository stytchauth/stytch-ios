# Sessions
Stytch user sessions are identified by a `Session` or `MemberSession` object, a session token and a JWT (JSON Web Token) that are authenticated on, and returned from, our authentication endpoints. The Stytch iOS SDK automatically persists these tokens and appends them to network requests as required, to make interacting with Stytch's authentication flows as simple as possible, and provides both Automatic and Manual session management helpers.

## Session Data Persistence
The Stytch iOS SDK persists to UserDefaults a few sets of encrypted values using AES256-GCM which are accessible across launches and help with session management:
1. The session token and JWT.
2. For the consumer client: `Session` and `User`.
3. For the B2B client: `MemberSession`, `Member` and `Organization`.

The `Session` / `MemberSession` object is the definitive source of truth for if the user is logged in or not as it contains an expiration date property for when the session expires.

## Automatic Session Management
When the Stytch iOS SDK is initialized, it decrypts the persisted session tokens and `Session` / `MemberSession` object, if any, and attempts to make a Sessions Authenticate call to ensure the session is still active/valid. On every authentication response, the SDK updates the in-memory and device-persisted session data with the latest data returned from the endpoint. In addition, once the SDK receives a valid session, it begins an automatic "heartbeat" job that checks for continued session validity in the background, roughly every three minutes. This heartbeat does not extend an existing session, it merely checks it's validity and updates the local data as appropriate. You as the developer can either observe changes in the session via the combine publisher shown below or directly though the `StytchClient.sessions.session` which both access the Session object stored (encrypted) in UserDefaults.

It is then good practice when using the Stytch iOS SDK to access any data that may have been updated via the heartbeat call through their cached values. Otherwise if you hold onto a reference of a response that contains authentication information in it, like token or user, you risk the those values returned in the response becoming stale. Values updated via the heartbeat are: `Session`, `User`, `MemberSession`, `Member` `Organization`, `sessionToken` and  `sessionJwt`. 

Examples for retrieving these cached values:
```swift
import StytchCore

// tokens
let sessionToken: SessionToken? = StytchClient.sessions.sessionToken
let sessionJwt: SessionToken? = StytchClient.sessions.sessionJwt

// consumer objects
let session: Session? = StytchClient.sessions.session
let user: User? = StytchClient.user.getSync()
```

### Observing Stytch Object Information

To unify the publishing of various Stytch object types such as `Session`, `User`, `MemberSession`, `Member`, and `Organization`, the SDK provides the `StytchObjectInfo` enum. This generic enum handles the publishing of objects in a way that avoids having to publish nil values.
* If an object is available for publishing, the `case available(T, Date)` is used, where T is the object and Date represents when it was last validated. The receiver can then determine if the object is within their acceptable time tolerance for use.
* If there is no object to publish, the `case unavailable` will be emitted instead. This ensures that the publisher never needs to send a nil value.

```swift
import StytchCore

public enum StytchObjectInfo<T: Equatable>: Equatable {
    case unavailable
    case available(T, Date)
}
```

Each of the five object types—`Session`, `User`, `MemberSession`, `Member`, and `Organization` has its own dedicated `onChange` publisher, ensuring that state changes for each type are handled individually. In the example below, we show the session publisher, but similar publishers exist for each of the other object types. This mechanism simplifies state management and ensures clean, consistent data flow throughout your app when interacting with these Stytch objects.

For session state changes specifally, you can subscribe to the `onSessionChange` Publisher:
```swift
import Combine
import StytchCore

var subscriptions: Set<AnyCancellable> = []

StytchClient.sessions.onSessionChange.sink { sessionInfo in
    switch sessionInfo {
    case let .available(session, lastValidatedAtDate):
        print("Session Available: \(session.expiresAt) - lastValidatedAtDate: \(lastValidatedAtDate)")
    case .unavailable:
        print("Session Unavailable")
    }
}.store(in: &subscriptions)
```

## Creating or Extending a Session
On all authentication requests, you can pass an optional parameter indicating the length of time a session should be valid for. This will be validated on the Stytch servers to ensure that it is within the minimum and maximum values configured in your Stytch dashboard (between 5 minutes and 1 year). 

Every authentication call that supplies a session duration (and succeeds!) will either create a session (if none exists), or extend the session duration by that length of time (if there is an active session).

With the exception of Sessions Authenticate calls, if you do not provide a session duration, the SDK will default it to 5 minutes. The Sessions Authenticate call is special, in that there is no default session duration if none is passed. This enables the "heartbeat" functionality discussed earlier. 

If you call authenticate with no `sessionDurationMinutes` it will merely respond with whether or not the session is active.
```swift
StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters()) 
```

If you do pass in a `sessionDurationMinutes` it will behave like all other endpoints and extend the existing session by 5 minutes.
```swift
StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters(sessionDurationMinutes: Minutes(rawValue: 5)))
``` 

## Manual Session Management
The [Sessions client](../Sources/StytchCore/StytchClient/StytchClient+Sessions.swift) provides an interface for managing the session.

Authenticating and Revoking Sessions:
```swift
import StytchCore

// Authenticate
let authenticateResponse = try await StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters())

// Revoke - clears all values for `Session`, `User`, `MemberSession`, `Member` `Organization`, `sessionToken` and  `sessionJwt`
let revokeResponse = try await StytchClient.sessions.revoke(parameters: Sessions.RevokeParameters())
```

Updating a session with tokens retrieved outside of the SDK (for instance, if you create or update a session on your backend, and want to hydrate a client application) can be done using the `updateSession` method:
```swift
import StytchCore

// `SessionTokens` require the caller to explicitly pass one of each type of non nil token in order to update a session.
if let sessionTokens = SessionTokens(jwt: .jwt("my-session-jwt"), opaque: .opaque("my-session-token")) {
    StytchClient.sessions.update(sessionTokens: sessionTokens)
    
    // Authenticate with the new tokens
    let authenticateResponse = try await StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters())
}
```

## Further Reading
For more information on the Stytch Sessions product, consult our [sessions guide](https://stytch.com/docs/guides/sessions/using-sessions).

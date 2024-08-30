# Sessions
Stytch user sessions are identified by a session token and a JWT (JSON Web Token) that are authenticated on, and returned from, our authentication endpoints. The Stytch iOS SDK automatically persists these tokens and appends them to network requests as required, to make interacting with Stytch's authentication flows as simple as possible, and provides both Automatic and Manual session management helpers.

## SDK Sessions At-A-Glance
### Session Data Persistence
The Stytch iOS SDK persists the session token and JWT to device by saving them to the Keychain, after encrypting them using AES256-GCM. The actual session and user data is stored in-memory only.

### Automatic Session Management
When the Stytch iOS SDK is initialized, it decrypts the persisted session token, if any, and makes a Sessions Authenticate call to ensure the session is still active/valid. If it is, it will automatically rehydrate the session and user data in memory; if not, it clears all persisted session tokens. On every authentication response, the SDK updates the in-memory and device-persisted session data with the latest data returned from the endpoint. 

In addition, once the SDK receives a valid session, it begins an automatic "heartbeat" job that checks for continued session validity in the background, roughly every three minutes. This heartbeat does not extend an existing session, it merely checks it's validity and updates the local data as appropriate. 

It is then good practice when using the Stytch iOS SDK to access any data that may have been updated via the heartbeat call through their cached values. Otherwise if you hold onto a reference of a response that contains authentication information in it, like token or user, you risk the those values returned in the response becoming stale. Values updated via the heartbeat are: `User`, `sessionToken`,  `sessionJwt` and `session`. Examples for retrieving these cached values are below. 

### Manual Session Management and Observation
The [Sessions client](../Sources/StytchCore/StytchClient/StytchClient+Sessions.swift) provides properties to retrieve the current session tokens; methods for authenticating, updating, and revoking sessions; and a publisher to listen for changes in session state.

To retrieve any existing session data, access the appropriate property or method, which will return the decrypted value to you, if it exists. This may be useful if you need to parse a JWT or use the token for a call from your backend, or need access to the in-memory session data:
```swift
import StytchCore

let sessionToken: SessionToken? = StytchClient.sessions.sessionToken
let sessionJwt: SessionToken? = StytchClient.sessions.sessionJwt
let sessionData: Session? = StytchClient.sessions.session
let user: User? = StytchClient.user.getSync()
```

Authenticating and Revoking sessions are similarly easy:
```swift
import StytchCore

let authenticateResponse = try await StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters())
let revokeResponse = try await StytchClient.sessions.revoke(parameters: Sessions.RevokeParameters())
```

Updating a session with tokens retrieved outside of the SDK (for instance, if you create or update a session on your backend, and want to hydrate a client application) can be done using the `updateSession` method:
```swift
import StytchCore

// `SessionTokens` require the caller to explicitly pass one of each type of non nil token in order to update a session.
if let sessionTokens = SessionTokens(jwt: .jwt("my-session-jwt"), opaque: .opaque("my-session-token")) {
    StytchClient.sessions.update(sessionTokens: sessionTokens)
}
```

Lastly, to listen for session state changes, you can subscribe to the `onAuthChange` Publisher:
```swift
import Combine
import StytchCore

var subscriptions: Set<AnyCancellable> = []

StytchClient.sessions.onAuthChange.sink { token in
    if let token = token {
        print("we have a session token")
    } else {
        print("we do not have a session token")
    }
}.store(in: &subscriptions)
```

## Creating or Extending a Session
On all authentication requests, you can pass an optional parameter indicating the length of time a session should be valid for. This will be validated on the Stytch servers to ensure that it is within the minimum and maximum values configured in your Stytch dashboard (between 5 minutes and 1 year). 

Every authentication call that supplies a session duration (and succeeds!) will either create a session (if none exists), or extend the session duration by that length of time (if there is an active session).

With the exception of Sessions Authenticate calls, if you do not provide a session duration, the SDK will default it to 5 minutes. The Sessions Authenticate call is special, in that there is no default session duration if none is passed. This enables the "heartbeat" functionality discussed earlier. 

If you call authenticate with no `sessionDuration` it will merely respond with whether or not the session is active.
```swift
StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters()) 
```

If you do pass in a `sessionDuration` it will behave like all other endpoints and extend the existing session by 5 minutes.
```swift
StytchClient.sessions.authenticate(parameters: Sessions.AuthenticateParameters(sessionDuration: Minutes(rawValue: 5)))
``` 

## Further Reading
For more information on the Stytch Sessions product, consult our [sessions guide](https://stytch.com/docs/guides/sessions/using-sessions).

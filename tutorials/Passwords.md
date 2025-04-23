# Passwords
Stytch offers a broad suite of passwordless authentication products, but for businesses and applications that depend on passwords, or are looking for a bridge between password-based and passwordless authentication, this SDK provides a fully featured Passwords product.

The Passwords client enables you to verify that a password meets your configured strength check policy; create new password-based users; authenticate users with an email and password; and reset passwords with an existing password, authenticated session, or by email.

## Implementation

### Strength Check
This method allows you to check whether or not the user’s provided password is valid, and to provide feedback to the user on how to increase the strength of their password.

This endpoint adapts to your Project's password strength configuration. If you're using  [zxcvbn](https://stytch.com/docs/guides/passwords/strength-policy), the default, your passwords are considered valid if the strength score is >= 3. If you're using  [LUDS](https://stytch.com/docs/guides/passwords/strength-policy), your passwords are considered valid if they meet the requirements that you've set with Stytch. You may update your password strength configuration in the [Stytch dashboard](https://stytch.com/dashboard/password-strength-config).

All password flows are subject to your configured strength check policy, so it's good practice to always perform a strength check before attempting to create or reset a user's password.

```swift
import StytchCore

func strengthCheck() {
    Task {
        do {
            let parameters = StytchClient.Passwords.StrengthCheckParameters(email: "user@email.com", password: "my user password")
            let response = try await StytchClient.passwords.strengthCheck(parameters: parameters)
            print(response.wrapped.validPassword)
        } catch {
            print(error.errorInfo)
        }
    }
}
```

### Create
This method creates a new user with a password, and can optionally create a new session for this user. 

When creating new Passwords users, it's good practice to enforce an email verification flow. We'd recommend checking out our [Email verification guide](https://stytch.com/docs/guides/passwords/email-verification/overview) for more information.

```swift
import StytchCore

func create() {
    Task {
        do {
            let parameters = StytchClient.Passwords.PasswordParameters(email: "user@email.com", password: "my user password")
            let response = try await StytchClient.passwords.create(parameters: parameters)
            print(response.wrapped.user)
            // The user was created successfully.
        } catch {
            print(error.errorInfo)
        }
    }
}
```

### Authenticate
This method is used for authenticating a user with an email address and password, and verifies that the user has a password currently set, and that the entered password is correct. 

```swift
import StytchCore

func authenticate() {
    Task {
        do {
            let parameters = StytchClient.Passwords.PasswordParameters(email: "user@email.com", password: "my user password")
            let response = try await StytchClient.passwords.authenticate(parameters: parameters)
            print(response.wrapped.session)
            // The user was logged in successfully
        } catch {
            print(error.errorInfo)
        }
    }
}
```

### Reset
From time to time, you may need to reset a user's password. The Stytch iOS SDK provides three flows for doing so, depending on the user's current state and needs:

1. If a user already knows their existing password, for instance if they just want to change their password for some reason, you can use the `StytchClient.passwords.resetByExistingPassword()` method
2. If a user is logged in, for instance with an Email Magic Link, but does not know their password, they can use their existing session to authenticate using the `StytchClient.passwords.resetBySession()` method
3. If a user is logged out and does not know their current password, they must reset their password by confirming their email address. This is a two part flow, that is similar to the [Email Magic Link](./EmailMagicLink.md) flow, and requires that you have configured [deeplinking](./Deeplinks.md) for your application.

#### Reset By Email Flow
First, you will start the resetByEmail flow:
```swift
import StytchCore

func resetByEmailStart() {
    Task {
        do {
            let parameters = StytchClient.Passwords.ResetByEmailStartParameters(email: "user@email.com")
            let response = try await StytchClient.passwords.resetByEmailStart(parameters: parameters)
            // The password reset email was successfuly sent
        } catch {
            print(error.errorInfo)
        }
    }
}
```

Once the user clicks the link in their email and returns to your application, you can store the token, prompt them for their new password, and use the token to reset the password:

This is an expansion on the [parsing deeplinks tutorial.](./Deeplinks.md)
```swift
import StytchCore

var passwordResetToken: String? = nil

func handle(url: URL) {
    Task {
        do {
            switch try await StytchClient.handle(url: url, sessionDurationMinutes: 5) {
            case let .handled(response):
                print("handled: \(response.session) - \(response.user)")
            case .notHandled:
                print("not handled")
            case let .manualHandlingRequired(tokenType, token):
                if tokenType == .passwordReset {
                    passwordResetToken = token
                }
                print("manualHandlingRequired: tokenType: \(tokenType) - token: \(token)")
            }
        } catch {
            print("handle url error: \(error)")
        }
    }
}
```

Use the `passwordResetToken` saved above when you call `StytchClient.passwords.resetByEmail`.
```swift
import StytchCore

func changePassword(newPassword: String) {
    Task {
        do {
            let parameters = StytchClient.Passwords.ResetByEmailParameters(token: newPassword, password: newPassword)
            let response = try await StytchClient.passwords.resetByEmail(parameters: parameters)
            print(response.wrapped.session)
            // The token was consumed and the user's password has been changed
        } catch {
            print(error.errorInfo)
        }
    }
}
```

## Further Reading
For more information on Stytch's Password product, check out the [guide](https://stytch.com/docs/guides/passwords/api).

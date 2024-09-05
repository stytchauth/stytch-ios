#  ``StytchCore``

Provides native access to the Stytch SDK methods for ultimate flexibility.

The iOS SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to [Stytch](https://stytch.com).

_To see in-depth examples of basic, intermediate, and advanced usage of the Stytch SDK, check out our <doc:stytch>!_

## Using Stytch

You'll interact with Stytch via the ``StytchClient`` (consumer apps) or ``StytchB2BClient`` (B2B apps), depending on your use case. Supported Stytch products are accessed via nested static variables on the client, e.g. `StytchClient.magicLinks.email`, where you can access the underlying methods, e.g. `StytchClient.magicLinks.email.loginOrCreate(parameters:)`.

### Consumer apps

| Consumer |
| --- |
| ``StytchClient/MagicLinks`` |
| ``StytchClient/Passwords`` |
| ``StytchClient/OTP`` |
| ``StytchClient/Biometrics`` |
| ``StytchClient/CryptoWallets`` |
| ``StytchClient/OAuth`` |
| ``StytchClient/TOTP`` |
| ``StytchClient/UserManagement`` |
| ``StytchClient/StytchClientSessions`` |

- ``StytchClient``
- ``Session``
- ``User``
- ``AuthenticateResponseData``

### B2B apps

| B2B |
| --- |
| ``StytchB2BClient/OAuth`` |
| ``StytchB2BClient/MagicLinks`` |
| ``StytchB2BClient/Discovery`` |
| ``StytchB2BClient/SSO`` |
| ``StytchB2BClient/Members`` |
| ``StytchB2BClient/Organizations`` |
| ``StytchB2BClient/OTP`` |
| ``StytchB2BClient/TOTP`` |
| ``StytchB2BClient/Passwords`` |
| ``StytchB2BClient/RBAC`` |
| ``StytchB2BClient/RecoveryCodes`` |
| ``StytchB2BClient/SearchManager`` |
| ``StytchB2BClient/StytchB2BClientSessions`` |

- ``StytchB2BClient``
- ``Organization``
- ``MemberSession``
- ``Member``
- ``B2BAuthenticateResponseData``

### Common

- ``SessionToken``
- ``SessionTokens``
- ``RBACPolicy`
- ``Response`
- ``StytchError`
- ``StytchAPIError`
- ``PKCECodePair`

`

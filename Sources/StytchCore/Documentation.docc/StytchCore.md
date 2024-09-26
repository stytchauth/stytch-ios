#  ``StytchCore``

Provides native access to the Stytch SDK methods for ultimate flexibility.

The iOS SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to [Stytch](https://stytch.com).

In addition to StytchCore we have a seperate dependency for our pre build UI framework, [StytchUI](https://stytchauth.github.io/stytch-ios/latest/StytchUI/documentation/stytchui/), which provides a out of the box solution for using Stytch. 

## Using Stytch

You'll interact with Stytch via the ``StytchClient`` (consumer apps) or ``StytchB2BClient`` (B2B apps), depending on your use case. Supported Stytch products are accessed via nested static variables on the client, e.g. `StytchClient.magicLinks.email`, where you can access the underlying methods, e.g. `StytchClient.magicLinks.email.loginOrCreate(parameters:)`.

### StytchClient

Property | Methods
--- | ---
``StytchClient/MagicLinks-swift.struct`` | ``StytchClient-swift.struct/MagicLinks-swift.struct/Email-swift.struct/loginOrCreate(parameters:)-9n8i5``, ``StytchClient-swift.struct/MagicLinks-swift.struct/Email-swift.struct/send(parameters:)-2i2l1``, ``StytchClient-swift.struct/MagicLinks-swift.struct/authenticate(parameters:)-27v6k``
``StytchClient/Passwords-swift.struct`` | ``StytchClient-swift.struct/Passwords-swift.struct/create(parameters:)-3gtlz``, ``StytchClient-swift.struct/Passwords-swift.struct/authenticate(parameters:)-9xbzg``, ``StytchClient-swift.struct/Passwords-swift.struct/resetByEmailStart(parameters:)-4xpf9``, ``StytchClient-swift.struct/Passwords-swift.struct/resetByEmail(parameters:)-79mm8``, ``StytchClient-swift.struct/Passwords-swift.struct/strengthCheck(parameters:)-1d3s7``
``StytchClient/OTP-swift.struct`` | ``StytchClient-swift.struct/OTP-swift.struct/loginOrCreate(parameters:)-c61b``, ``StytchClient-swift.struct/OTP-swift.struct/send(parameters:)-3xcc9``, ``StytchClient-swift.struct/OTP-swift.struct/authenticate(parameters:)-5ums0``
``StytchClient/Biometrics-swift.struct`` | ``StytchClient-swift.struct/Biometrics-swift.struct/register(parameters:)-m8w7``, ``StytchClient-swift.struct/Biometrics-swift.struct/authenticate(parameters:)-8ycmb``, ``StytchClient-swift.struct/Biometrics-swift.struct/registrationAvailable``, ``StytchClient-swift.struct/Biometrics-swift.struct/removeRegistration()-7a8j9``
``StytchClient/OAuth-swift.struct/ThirdParty`` | ``StytchClient-swift.struct/OAuth-swift.struct/ThirdParty-swift.struct/start(configuration:)``, ``StytchClient-swift.struct/OAuth-swift.struct/authenticate(parameters:)-3tjwd``
``StytchClient/OAuth-swift.struct/Apple-swift.struct`` | ``StytchClient-swift.struct/OAuth-swift.struct/Apple-swift.struct/start(parameters:)-5rxqg``
``StytchClient/TOTP-swift.struct`` | ``StytchClient-swift.struct/TOTP-swift.struct/create(parameters:)-437r4``, ``StytchClient-swift.struct/TOTP-swift.struct/authenticate(parameters:)-2ck6w``, ``StytchClient-swift.struct/TOTP-swift.struct/recoveryCodes()-mbxc``, ``StytchClient-swift.struct/TOTP-swift.struct/recover(parameters:)-9swfk``
``StytchClient/Sessions-swift.struct`` | ``StytchClient-swift.struct/Sessions-swift.struct/revoke(parameters:)-7lw27``, ``StytchClient-swift.struct/Sessions-swift.struct/authenticate(parameters:)-7gegg``
``StytchClient/UserManagement-swift.struct`` | ``StytchClient-swift.struct/UserManagement-swift.struct/getSync()``, ``StytchClient-swift.struct/UserManagement-swift.struct/get()-57gt5``, ``StytchClient-swift.struct/UserManagement-swift.struct/deleteFactor(_:)-5nh6h``
``StytchClient/CryptoWallets-swift.struct`` | ``StytchClient-swift.struct/CryptoWallets-swift.struct/authenticateStart(parameters:)-23wt7``, ``StytchClient-swift.struct/CryptoWallets-swift.struct/authenticate(parameters:)-8ea9t``

### StytchB2BClient

Property | Methods
--- | ---
``StytchB2BClient/MagicLinks-swift.struct`` | ``StytchB2BClient-swift.struct/MagicLinks-swift.struct/Email-swift.struct/loginOrSignup(parameters:)-6rrup``, ``StytchB2BClient-swift.struct/MagicLinks-swift.struct/authenticate(parameters:)-9bkrj``, ``StytchB2BClient-swift.struct/MagicLinks-swift.struct/Email-swift.struct/discoverySend(parameters:)-1opgc``, ``StytchB2BClient-swift.struct/MagicLinks-swift.struct/discoveryAuthenticate(parameters:)-4vo9v``
``StytchB2BClient/Discovery-swift.struct`` | ``StytchB2BClient-swift.struct/Discovery-swift.struct/createOrganization(parameters:)-7hypb``, ``StytchB2BClient-swift.struct/Discovery-swift.struct/listOrganizations(parameters:)-4yarj``, ``StytchB2BClient-swift.struct/Discovery-swift.struct/exchangeIntermediateSession(parameters:)-8uvs8``
``StytchB2BClient/SSO-swift.struct`` | ``StytchB2BClient-swift.struct/SSO-swift.struct/start(parameters:)-6ik51``, ``StytchB2BClient-swift.struct/SSO-swift.struct/authenticate(parameters:)-1ncp1``
``StytchB2BClient/Sessions-swift.struct`` | ``StytchB2BClient-swift.struct/Sessions-swift.struct/revoke(parameters:)-7lw27``, ``StytchB2BClient-swift.struct/Sessions-swift.struct/authenticate(parameters:)-7gegg``
``StytchB2BClient/Members-swift.struct`` | ``StytchB2BClient-swift.struct/Members-swift.struct/getSync()``, ``StytchB2BClient-swift.struct/Members-swift.struct/get()-7fdhf``
``StytchB2BClient/Organizations-swift.struct`` | ``StytchB2BClient-swift.struct/Organizations-swift.struct/getSync()``, ``StytchB2BClient-swift.struct/Organizations-swift.struct/get()-2esfw``
``StytchB2BClient/OAuth-swift.struct`` | ``StytchB2BClient-swift.struct/OAuth-swift.struct/ThirdParty-swift.struct/start(configuration:)``, ``StytchB2BClient-swift.struct/OAuth-swift.struct/authenticate(parameters:)-80abl``
``StytchB2BClient/OTP-swift.struct`` | ``StytchB2BClient-swift.struct/OTP-swift.struct/send(parameters:)-3xcc9``, ``StytchB2BClient-swift.struct/OTP-swift.struct/authenticate(parameters:)-5ums0``
``StytchB2BClient/TOTP-swift.struct`` | ``StytchB2BClient-swift.struct/TOTP-swift.struct/create(parameters:)-437r4``, ``StytchB2BClient-swift.struct/TOTP-swift.struct/authenticate(parameters:)-2ck6w``
``StytchB2BClient/Passwords-swift.struct`` | ``StytchB2BClient-swift.struct/Passwords-swift.struct/authenticate(parameters:)-63kup``, ``StytchB2BClient-swift.struct/Passwords-swift.struct/resetByEmailStart(parameters:)-24ggc``, ``StytchB2BClient-swift.struct/Passwords-swift.struct/resetByEmail(parameters:)-6r4gk``, ``StytchB2BClient-swift.struct/Passwords-swift.struct/resetByExistingPassword(parameters:)-2ju8w``, ``StytchB2BClient-swift.struct/Passwords-swift.struct/resetBySession(parameters:)-834cf``, ``StytchB2BClient-swift.struct/Passwords-swift.struct/strengthCheck(parameters:)-4uctk``
``StytchB2BClient/RBAC-swift.struct`` | ``StytchB2BClient-swift.struct/RBAC-swift.struct/allPermissions()-89p7d``, ``StytchB2BClient-swift.struct/RBAC-swift.struct/isAuthorized(resourceId:action:)-3qmjb``, ``StytchB2BClient-swift.struct/RBAC-swift.struct/isAuthorizedSync(resourceId:action:)``
``StytchB2BClient/RecoveryCodes-swift.struct`` | ``StytchB2BClient-swift.struct/RecoveryCodes-swift.struct/get()-1dlsm``, ``StytchB2BClient-swift.struct/RecoveryCodes-swift.struct/rotate()-9wyz3``, ``StytchB2BClient-swift.struct/RecoveryCodes-swift.struct/recover(parameters:)-7r6fr``
``StytchB2BClient/SearchManager-swift.struct`` | ``StytchB2BClient-swift.struct/SearchManager-swift.struct/searchMember(searchMemberParameters:)-9nw94``, ``StytchB2BClient-swift.struct/SearchManager-swift.struct/searchOrganization(searchOrganizationParameters:)-2a7yp``


## Topics

### Consumer

- ``StytchClient``
- ``AuthenticateResponseData``
- ``Session``
- ``User``

### B2B

- ``StytchB2BClient``
- ``B2BAuthenticateResponseData``
- ``B2BMFAAuthenticateResponseData``
- ``MemberSession``
- ``Organization``
- ``Member``

### Common

- ``SessionToken``
- ``SessionTokens``
- ``RBACPolicy``
- ``Response``
- ``StytchError``
- ``StytchAPIError``
- ``PKCECodePair``

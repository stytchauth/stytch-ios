#  ``StytchCore``

Provides native iOS access to the Stytch SDK methods for ultimate flexibility.

The iOS SDK provides methods that communicate directly with the Stytch API. These help you get up and running with Stytch faster by removing the need to create endpoints on your backend to make requests to [Stytch](https://stytch.com).

In addition to StytchCore we have a seperate dependency for our pre built UI framework, [StytchUI](https://stytchauth.github.io/stytch-ios/latest/StytchUI/documentation/stytchui/), which provides a out of the box solution for using Stytch. 

[Stytch iOS Github Repo](https://github.com/stytchauth/stytch-ios)

## Using Stytch

You'll interact with Stytch via the ``StytchClient`` (consumer apps) or ``StytchB2BClient`` (B2B apps), depending on your use case. Supported Stytch products are accessed via nested static variables on the client, e.g. `StytchClient.magicLinks.email`, where you can access the underlying methods, e.g. `StytchClient.magicLinks.email.loginOrCreate(parameters:)`.

### StytchClient

Property | Methods
--- | ---
``StytchClient/MagicLinks-swift.struct`` | ``StytchClient/MagicLinks-swift.struct/Email-swift.struct/loginOrCreate(parameters:)-9n8i5``<br>``StytchClient/MagicLinks-swift.struct/Email-swift.struct/send(parameters:)-2i2l1``<br>``StytchClient/MagicLinks-swift.struct/authenticate(parameters:)-27v6k``
``StytchClient/Passwords-swift.struct`` | ``StytchClient/Passwords-swift.struct/create(parameters:)-3gtlz``, ``StytchClient/Passwords-swift.struct/authenticate(parameters:)-9xbzg``, ``StytchClient/Passwords-swift.struct/resetByEmailStart(parameters:)-4xpf9``, ``StytchClient/Passwords-swift.struct/resetByEmail(parameters:)-79mm8``, ``StytchClient/Passwords-swift.struct/strengthCheck(parameters:)-1d3s7``
``StytchClient/OTP`` | ``StytchClient/OTP/loginOrCreate(parameters:)-c61b``, ``StytchClient/OTP/send(parameters:)-3xcc9``, ``StytchClient/OTP/authenticate(parameters:)-5ums0``
``StytchClient/Biometrics-swift.struct`` | ``StytchClient/Biometrics-swift.struct/register(parameters:)-m8w7``, ``StytchClient/Biometrics-swift.struct/authenticate(parameters:)-8ycmb``, ``StytchClient/Biometrics-swift.struct/registrationAvailable``, ``StytchClient/Biometrics-swift.struct/removeRegistration()-7a8j9``
``StytchClient/TOTP`` | ``StytchClient/TOTP/create(parameters:)-437r4``, ``StytchClient/TOTP/authenticate(parameters:)-2ck6w``, ``StytchClient/TOTP/recoveryCodes()-mbxc``, ``StytchClient/TOTP/recover(parameters:)-9swfk``
``StytchClient/Sessions-swift.struct`` | ``StytchClient/Sessions-swift.struct/revoke(parameters:)-37wah``, ``StytchClient/Sessions-swift.struct/authenticate(parameters:)-7l8kp``
``StytchClient/UserManagement`` | ``StytchClient/UserManagement/getSync()``, ``StytchClient/UserManagement/get()-57gt5``, ``StytchClient/UserManagement/deleteFactor(_:)-7tqlw``
``StytchClient/CryptoWallets-swift.struct`` | ``StytchClient/CryptoWallets-swift.struct/authenticateStart(parameters:)-23wt7``, ``StytchClient/CryptoWallets-swift.struct/authenticate(parameters:)-8ea9t``
``StytchClient/OAuth-swift.struct`` | ``StytchClient/OAuth-swift.struct/authenticate(parameters:)-3tjwd``
``StytchClient/OAuth-swift.struct/ThirdParty`` | ``StytchClient/OAuth-swift.struct/ThirdParty/start(configuration:)-75pid``
``StytchClient/OAuth-swift.struct/Apple-swift.struct`` | ``StytchClient/OAuth-swift.struct/Apple-swift.struct/start(parameters:)-5rxqg``

### StytchB2BClient

Property | Methods
--- | ---
``StytchB2BClient/MagicLinks-swift.struct`` | ``StytchB2BClient/MagicLinks-swift.struct/Email-swift.struct/loginOrSignup(parameters:)-6rrup``, ``StytchB2BClient/MagicLinks-swift.struct/authenticate(parameters:)-40aub``, ``StytchB2BClient/MagicLinks-swift.struct/Email-swift.struct/discoverySend(parameters:)-1opgc``, ``StytchB2BClient/MagicLinks-swift.struct/discoveryAuthenticate(parameters:)-4vo9v``
``StytchB2BClient/Discovery-swift.struct`` | ``StytchB2BClient/Discovery-swift.struct/createOrganization(parameters:)-7hypb``, ``StytchB2BClient/Discovery-swift.struct/listOrganizations()-57fl3``, ``StytchB2BClient/Discovery-swift.struct/exchangeIntermediateSession(parameters:)-8uvs8``
``StytchB2BClient/SSO-swift.struct`` | ``StytchB2BClient/SSO-swift.struct/start(configuration:)-2iami``, ``StytchB2BClient/SSO-swift.struct/authenticate(parameters:)-49s4``
``StytchB2BClient/Sessions-swift.struct`` | ``StytchB2BClient/Sessions-swift.struct/revoke(parameters:)-3e4jb``, ``StytchB2BClient/Sessions-swift.struct/authenticate(parameters:)-8909t``
``StytchB2BClient/Members`` | ``StytchB2BClient/Members/getSync()``, ``StytchB2BClient/Members/get()-7fdhf``
``StytchB2BClient/Organizations-swift.struct`` | ``StytchB2BClient/Organizations-swift.struct/getSync()``, ``StytchB2BClient/Organizations-swift.struct/get()-2esfw``
``StytchB2BClient/OTP-swift.struct`` | ``StytchB2BClient/OTP-swift.struct/send(parameters:)-4jutd``, ``StytchB2BClient/OTP-swift.struct/authenticate(parameters:)-3gx7t``
``StytchB2BClient/TOTP-swift.struct`` | ``StytchB2BClient/TOTP-swift.struct/create(parameters:)-65xjg``, ``StytchB2BClient/TOTP-swift.struct/authenticate(parameters:)-70014``
``StytchB2BClient/Passwords-swift.struct`` | ``StytchB2BClient/Passwords-swift.struct/authenticate(parameters:)-63kup``, ``StytchB2BClient/Passwords-swift.struct/resetByEmailStart(parameters:)-24ggc``, ``StytchB2BClient/Passwords-swift.struct/resetByEmail(parameters:)-6r4gk``, ``StytchB2BClient/Passwords-swift.struct/resetByExistingPassword(parameters:)-2ju8w``, ``StytchB2BClient/Passwords-swift.struct/resetBySession(parameters:)-834cf``, ``StytchB2BClient/Passwords-swift.struct/strengthCheck(parameters:)-4uctk``
``StytchB2BClient/RBAC-swift.struct`` | ``StytchB2BClient/RBAC-swift.struct/allPermissions()-89p7d``, ``StytchB2BClient/RBAC-swift.struct/isAuthorized(resourceId:action:)-3qmjb``, ``StytchB2BClient/RBAC-swift.struct/isAuthorizedSync(resourceId:action:)``
``StytchB2BClient/RecoveryCodes-swift.struct`` | ``StytchB2BClient/RecoveryCodes-swift.struct/get()-1dlsm``, ``StytchB2BClient/RecoveryCodes-swift.struct/rotate()-9wyz3``, ``StytchB2BClient/RecoveryCodes-swift.struct/recover(parameters:)-7r6fr``
``StytchB2BClient/SearchManager-swift.struct`` | ``StytchB2BClient/SearchManager-swift.struct/searchMember(searchMemberParameters:)-9nw94``, ``StytchB2BClient/SearchManager-swift.struct/searchOrganization(searchOrganizationParameters:)-2a7yp``
``StytchB2BClient/OAuth-swift.struct`` | ``StytchB2BClient/OAuth-swift.struct/authenticate(parameters:)-80abl``
``StytchB2BClient/OAuth-swift.struct/ThirdParty`` | ``StytchB2BClient/OAuth-swift.struct/ThirdParty/start(configuration:)-956wc``
``StytchB2BClient/OAuth-swift.struct/Discovery-swift.struct`` | ``StytchB2BClient/OAuth-swift.struct/Discovery-swift.struct/authenticate(parameters:)-4u0xy``
``StytchB2BClient/OAuth-swift.struct/ThirdParty/Discovery-swift.struct`` | ``StytchB2BClient/OAuth-swift.struct/ThirdParty/Discovery-swift.struct/start(configuration:)-6pgj5``

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

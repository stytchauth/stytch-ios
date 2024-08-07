<div align=center>

![Stytch iOS SDK](Resources/Assets/Wordmark-dark-mode.png#gh-dark-mode-only)
![Stytch iOS SDK](Resources/Assets/Wordmark-light-mode.png#gh-light-mode-only)

![Test Status](https://github.com/stytchauth/stytch-ios/actions/workflows/test.yml/badge.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS-333333.svg)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D)

</div>

* [Getting Started](#getting-started)
  * [What is Stytch?](#what-is-stytch)
  * [Why should I use the Stytch SDK?](#why-should-i-use-the-stytch-sdk)
  * [What can I do with the Stytch SDK?](#what-can-i-do-with-the-stytch-sdk)
    * [Consumer apps](#consumer-apps)
    * [B2B apps](#b2b-apps)
    * [Async Options](#async-options)
  * [How do I start using Stytch?](#how-do-i-start-using-stytch)
* [Requirements](#requirements)
  * [Passkeys](#passkeys)
* [Installation](#installation)
* [Usage](#usage)
    * [Consumer apps](#consumer-apps)
    * [B2B apps](#b2b-apps)
  * [Configuration](#configuration)
  * [Authenticating](#authenticating)
* [Documentation](#documentation)
* [FAQ](#faq)
* [License](#license)

## Getting Started

### What is Stytch?

[Stytch](https://stytch.com) is an authentication platform, written by developers for developers, with a focus on improving security and user experience via passwordless authentication. Stytch offers direct API integrations, language-specific libraries, and SDKs (like this one) to make the process of setting up an authentication flow for your app as easy as possible.

### Why should I use the Stytch SDK?

Stytch's SDKs make it simple to seamlessly onboard, authenticate, and engage users. The iOS SDK provides the easiest way for you to use Stytch on Apple platforms. With just a few lines of code, you can easily authenticate your users and get back to focusing on the core of your product.

``` swift
import StytchCore

// Initiate login/signup
_ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: userEmail))

// Later, handle the subsequent deeplink
_ = try await StytchClient.handle(url: deeplinkUrl)
```

### What can I do with the Stytch SDK?

There are a number of authentication products currently supported by the SDK, with additional functionality coming in the near future! The full list of currently supported products is as follows:

#### Consumer apps

- Magic links
    - Send/authenticate magic links via Email
- Biometrics
    - Authenticate via FaceID/TouchID
- OTPs
    - Send/authenticate one-time passcodes via SMS, WhatsApp, Email
- OAuth
    - Authenticate with external identity providers such as: Apple, Google, Facebook, GitHub, etc.
- Passwords
    - Create or authenticate a user
    - Check password strength
    - Reset a password
- TOTPs
    - Create a new time-based one-time passcode (TOTP) secret for storage in an authenticator app
    - Authenticate a TOTP
    - Get a user's recovery codes
    - Authenticate a recovery code
- Sessions
    - Authenticate/refresh an existing session
    - Revoke a session (Sign out)
- Passkeys
    - Register/Authenticate with Passkeys
- User Management
    - Get or fetch the current user object (sync/cached or async options available)
    - Delete factors by id from the current user

#### B2B apps

- Magic links
    - Send/authenticate magic links via Email
    - Send/authenticate discovery magic links via Email
- Passwords
    - Authenticate a member
    - Check password strength
    - Reset a password
- Discovery
    - Discover member's existing organizations
    - Create a new organization
    - Exchange a session for a different organization
- SSO
    - Start/authenticate an SSO authentication flow
- Sessions
    - Authenticate/refresh an existing session
    - Revoke a session (Sign out)
- Members
    - Get or fetch the current member object (sync/cached or async options available)
- Organizations
    - Get or fetch the current members's organization
    
#### Async Options

The SDK provides several different mechanisms for handling the asynchronous code, so you can choose what best suits your needs.

- `Async/Await`
- `Combine`
- `Callbacks`

### How do I start using Stytch?

If you are completely new to Stytch, prior to using the SDK you will first need to visit [Stytch's homepage](https://stytch.com), sign up, and create a new project in the [dashboard](https://stytch.com/dashboard/home). You'll then need to adjust your [SDK configuration](https://stytch.com/dashboard/sdk-configuration) — adding your app's bundle id to `Authorized environments` and enabling any `Auth methods` you wish to use.

_To see in-depth examples of basic, intermediate, and advanced usage of the Stytch SDK, check out our [Stytch Tutorials](https://stytchauth.github.io/stytch-ios/main/tutorials/stytch)!_

## Requirements

The Stytch iOS SDK is compatible with apps targeting the following Apple platforms:
- iOS 13+
- macOS 10.15+
- tvOS 13+

### Passkeys
To enable passkey support for your iOS app, associate your app with a website that your app owns. You can declare this association by following the instructions [here](https://developer.apple.com/documentation/xcode/supporting-associated-domains), specifically as they relate to the `webcredentials` configuration.

## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

1. Open Xcode
1. File > Add Packages
1. Enter https://github.com/stytchauth/stytch-ios
1. Choose Package Requirements (Up to next minor, up to next major, etc)
1. In your Build Settings, under `Other Linker Flags`, add `-ObjC`

## Usage

### Configuration

To start using one of the Stytch clients (StytchClient or StytchB2BClient), you must configure it via one of two techniques: 1) Automatically, by including a `StytchConfiguration.plist` file in your main app bundle ([example](Stytch/Client/Shared/StytchConfiguration.plist)) or 2) Programmatically at app launch (see `.task {}` [below](#manual-configuration--deeplink-handling).)

#### Associated Domains

If you are using a redirect authentication product (Email Magic Links/OAuth) you will need to set up Associated Domains on [your website](https://developer.apple.com/documentation/Xcode/supporting-associated-domains) and in your app's entitlements ([example](Stytch/Client/macOS/macOS.entitlements)).

![Entitlements screenshot](Resources/Assets/Entitlements-dark-mode.png#gh-dark-mode-only)
![Entitlements screenshot](Resources/Assets/Entitlements-light-mode.png#gh-light-mode-only)

#### Manual Configuration / Deeplink Handling

This example shows a hypothetical SwiftUI App file, with custom configuration (see `.task {}`), as well as deeplink/universal link handling.

``` swift
@main
struct YourApp: App {
    private let stytchPublicToken = "your-public-token" // Perhaps fetched from your backend

    @State private var session: Session?

    var body: some Scene {
        WindowGroup {
            ContentView(session: session) 
                .task {
                    StytchClient.configure(publicToken: stytchPublicToken)
                }
                // Handle web-browsing/universal deeplinks
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    handle(url: url)
                }
                // Handle deeplinks
                .onOpenURL(perform: handle(url:))
        }
    }

    private func handle(url: URL) {
        Task {
            do {
                switch try await StytchClient.handle(url: url) {
                case let .handled(response):
                    self.session = response.session
                case .notHandled:
                    // Handle via alternative means
                }
            } catch { ... }
        }
    }
}
```

### Authenticating

As seen in [What can I do with the Stytch SDK?](#what-can-i-do-with-the-stytch-sdk), there are a number of different authentication products available. Here, we'll showcase a simple example of using the OTP product.

#### One-time Passcodes

This example shows a hypothetical class you could use to manage SMS authentication in your app, delegating much of the work to the StytchClient under the hood.

``` swift
import StytchCore

final class SMSAuthenticationController {
    private let onAuthenticate: (Session, User) -> Void
    private var methodId: String?

    // phoneNumber must be a valid phone number in E.164 format (e.g. +1XXXXXXXXXX)
    func login(phoneNumber: String) async throws {
        let response = try await StytchClient.otps.loginOrCreate(
            parameters: .init(deliveryMethod: .sms(phoneNumber: phoneNumber))
        )
        // Store the methodId for the subsequent `authenticate(code:)` call
        methodId = response.methodId
    }

    func authenticate(code: String) async throws {
        guard let methodId = methodId else { throw YourCustomError }
        
        let response = try await StytchClient.otps.authenticate(
            parameters: .init(code: code, methodId: methodId)
        )

        onAuthenticate(response.session, response.user)
    }
}
```

## Documentation

Full reference documentation is available for [StytchCore](https://stytchauth.github.io/stytch-ios/main/StytchCore/documentation/stytchcore/) and [StytchUI](https://stytchauth.github.io/stytch-ios/main/StytchUI/documentation/stytchui/).

## FAQ

1. How does the SDK compare to the API?
    1. The SDK, for the most part, mirrors the API directly — though it provides a more opinionated take on interacting with these methods; managing local state on your behalf and introducing some defaults (viewable in the corresponding init/function reference docs). A primary benefit of using the SDK is that you can interact with Stytch directly from the client, without relaying calls through your backend.
1. What are the some of the default behaviors of the SDK?
    1. A few things here: 1) the session token/JWT will be stored in/retrieved from the system Keychain, so will safely persist across app launches. 2) The session and user objects are cached in memory by the SDK, though these must first be received by a successful `authenticate` call. 3) After a successful authentication call, the SDK will begin polling in the background to refresh the session and its corresponding JWT, to ensure the JWT is always valid (the JWT expires every 5 minutes, regardless of the session expiration.)
1. Are there guides or sample apps available to see this in use?
    1. Yes! There is a UIKit example consumer app available [here](https://github.com/stytchauth/stytch-ios-uikit-example). Also, there is a [SwiftUI macOS/iOS Consumer app](https://github.com/stytchauth/stytch-ios/tree/main/Stytch/Client) and a [UIKit iOS B2B app](https://github.com/stytchauth/stytch-ios/tree/main/Stytch/B2BWorkbench) included in this repo.

### Questions?

Feel free to reach out any time at [support@stytch.com](mailto:support@stytch.com), in our [Slack](https://stytch.com/docs/resources/support/overview), or in our [Forum](https://forum.stytch.com).

## License

The Stytch iOS SDK is released under the MIT license. See [LICENSE](LICENSE) for details.

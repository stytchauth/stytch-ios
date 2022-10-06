![Stytch Swift SDK](Resources/Assets/Wordmark-dark-mode.png#gh-dark-mode-only)
![Stytch Swift SDK](Resources/Assets/Wordmark-light-mode.png#gh-light-mode-only)

![Test Status](https://github.com/stytchauth/stytch-swift/actions/workflows/test.yml/badge.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS-333333.svg)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D)
![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Stytch.svg)

* [Getting Started](#getting-started)
  * [What is Stytch?](#what-is-stytch)
  * [Why should I use the Stytch SDK?](#why-should-i-use-the-stytch-sdk)
  * [What can I do with the Stytch SDK?](#what-can-i-do-with-the-stytch-sdk)
    * [Async Options](#async-options)
  * [How do I start using Stytch?](#how-do-i-start-using-stytch)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
  * [Configuration](#configuration)
  * [Authenticating](#authenticating)
* [Documentation](#documentation)
* [FAQ](#faq)
* [License](#license)

## Getting Started

### What is Stytch?

[Stytch](https://stytch.com) is an authentication platform, written by developers for developers, with a focus on improving security and user experience via passwordless authentication. Stytch offers direct API integrations, language-specific libraries, and SDKs (like this one) to make the process of setting up an authentication flow for your app as easy as possible.

### Why should I use the Stytch SDK?

Stytch's SDKs make it simple to seamlessly onboard, authenticate, and engage users. The Swift SDK provides the easiest way for you to use Stytch on Apple platforms. With just a few lines of code, you can easily authenticate your users and get back to focusing on the core of your product.

``` swift
import StytchCore

// Initiate login/signup
_ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: .init(email: userEmail))

// Later, handle the subsequent deeplink
_ = try await StytchClient.handle(url: deeplinkUrl)
```

### What can I do with the Stytch SDK?

There are a number of authentication products currently supported by the SDK, with additional functionality coming in the near future! The full list of currently supported products is as follows:

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
- Sessions
    - Authenticate/refresh an existing session
    - Revoke a session (Sign out)

#### Async Options

The SDK provides several different mechanisms for handling the asynchronous code, so you can choose what best suits your needs.

- `Async/Await`
- `Combine`
- `Callbacks`

### How do I start using Stytch?

If you are completely new to Stytch, prior to using the SDK you will first need to visit [Stytch's homepage](https://stytch.com), sign up, and create a new project in the [dashboard](https://stytch.com/dashboard/home). You'll then need to adjust your [SDK configuration](https://stytch.com/dashboard/sdk-configuration) — adding your app's bundle id to `Authorized environments` and enabling any `Auth methods` you wish to use.

## Requirements

The Stytch Swift SDK is compatible with apps targeting the following Apple platforms:
- iOS 13+
- macOS 10.15+
- tvOS 13+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

1. Open Xcode
1. File > Add Packages
1. Enter https://github.com/stytchauth/stytch-swift
1. Choose Package Requirements (Up to next minor, up to next major, etc)

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa. To integrate the Stytch Swift SDK into your Xcode project, add the following to your Cartfile.
```
binary "https://public-assets-stytch-com.s3.amazonaws.com/sdks/swift/carthage/StytchCore.json"
```

### CocoaPods
[CocoaPods](https://cocoapods.org) is a centralized dependency manager for Swift and Objective-C Cocoa projects. To integrate the Stytch Swift SDK into your Xcode project, add the following to your Podfile.

```
pod 'Stytch/StytchCore'
```

Unlike with the other dependency managers, when using CocoaPods you'll import `Stytch` vs `StytchCore`.

## Usage

### Configuration

To start using the StytchClient, you must configure it via one of two techniques: 1) Automatically, by including a `StytchConfiguration.plist` file in your main app bundle ([example](StytchDemo/Client/Shared/StytchConfiguration.plist)) or 2) Programmatically at app launch (see `.task {}` [below](#manual-configuration--deeplink-handling).)

#### Associated Domains
If you are using a redirect authentication product (Email Magic Links/OAuth) you will need to set up Associated Domains on [your website](https://developer.apple.com/documentation/Xcode/supporting-associated-domains) and in your app's entitlements ([example](StytchDemo/Client/macOS/macOS.entitlements)).

![Entitlements screenshot](Resources/Assets/Entitlements-dark-mode.png#gh-dark-mode-only)
![Entitlements screenshot](Resources/Assets/Entitlements-light-mode.png#gh-light-mode-only)

#### Manual Configuration / Deeplink Handling

This example shows a hypothetical SwiftUI App file, with custom configuration (see `.task {}`), as well as deeplink/universal link handling.

``` swift
@main
struct YourApp: App {
    private let stytchPublicToken = "your-public-token"
    private let hostUrl = URL(string: "https://your-backend.com")!

    @State private var session: Session?

    var body: some Scene {
        WindowGroup {
            ContentView(session: session) 
                .task {
                    StytchClient.configure(publicToken: stytchPublicToken, hostUrl: hostUrl)
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

Full reference documentation is available [here](https://stytchauth.github.io/stytch-swift/documentation/stytchcore/).

## FAQ

1. How does the SDK compare to the API?
    1. The SDK, for the most part, mirrors the API directly — though it provides a more opinionated take on interacting with these methods; managing local state on your behalf and introducing some defaults (viewable in the corresponding init/function reference docs). A primary benefit of using the SDK is that you can interact with Stytch directly from the client, without relaying calls through your backend.
1. What are the some of the default behaviors of the SDK?
    1. A few things here: 1) the session token/JWT will be stored in/retrieved from the system Keychain, so will safely persist across app launches. 2) The session and user objects are not cached by the SDK, these must be pulled from the `authenticate` responses and stored by the application. 3) After a successful authentication call, the SDK will begin polling in the background to refresh the session and its corresponding JWT, to ensure the JWT is always valid (the JWT expires every 5 minutes, regardless of the session expiration.)
1. Are there guides or sample apps available to see this in use?
    1. Yes! There is a SwiftUI macOS/iOS Demo App included in this repo, available [here](https://github.com/stytchauth/stytch-swift/tree/main/StytchDemo).

### Questions?

Feel free to reach out any time at support@stytch.com or in our [Slack](https://join.slack.com/t/stytch/shared_invite/zt-nil4wo92-jApJ9Cl32cJbEd9esKkvyg)

## License

The Stytch Swift SDK is released under the MIT license. See [LICENSE](LICENSE) for details.

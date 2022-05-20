![Stytch Swift SDK](Resources/Assets/Wordmark-dark-mode.png#gh-dark-mode-only)
![Stytch Swift SDK](Resources/Assets/Wordmark-light-mode.png#gh-light-mode-only)

![Test Status](https://github.com/stytchauth/stytch-swift/actions/workflows/test.yml/badge.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS-333333.svg)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D)
![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/StytchCore.svg)


Stytch's SDKs make it simple to seamlessly onboard, authenticate, and engage users. Improve security and user experience with passwordless authentication. The Swift SDK provides the easiest way for you to use Stytch on Apple platforms.

* [Requirements](#requirements)
* [Installation](#installation)
* [Getting Started](#getting-started)
  * [Configuration](#configuration)
  * [Authenticating](#authenticating)
* [Documentation](#documentation)

#### Supported Products

- Email magic links
- One-time passcodes (SMS, WhatsApp, Email)
- Session management

Additional functionality coming in the near future!

#### Async Options

- `Async/Await`
- `Combine`
- ` Callbacks`

## Requirements

The Stytch Swift SDK is compatible with apps targeting the following Apple platforms:
- iOS 11.3+
- macOS 10.13+
- tvOS 11+

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
binary "https://stytch-swift.github.io/StytchCore.json"
```

### CocoaPods
[CocoaPods](https://cocoapods.org) is a centralized dependency manager for Swift and Objective-C Cocoa projects. To integrate the Stytch Swift SDK into your Xcode project, add the following to your Podfile.

```
pod 'StytchCore'
```

## Getting Started

### Configuration

To start using Stytch, you must configure it via one of two techniques: 1) Automatically, by including a `StytchConfiguration.plist` file in your main app bundle ([example](StytchDemo/Shared/StytchConfiguration.plist)) or 2) Programmatically at app launch (see `.task {}` [below](#manual-configuration--deeplink-handling).)

#### Associated Domains
If you are using a redirect authentication product (Email Magic Links/OAuth) you will need to set up Associated Domains on [your website](https://developer.apple.com/documentation/Xcode/supporting-associated-domains) and in your app's entitlements ([example](StytchDemo/macOS/macOS.entitlements)).

![Entitlements screenshot](Resources/Assets/Entitlements-dark-mode.png#gh-dark-mode-only)
![Entitlements screenshot](Resources/Assets/Entitlements-light-mode.png#gh-light-mode-only)

#### Manual Configuration / Deeplink Handling

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
                // Handle web-browsing deeplinks
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
            } catch {
                handle(error: error)
            }
        }
    }
}
```

### Authenticating

#### One-time Passcodes

``` swift
import StytchCore

final class SMSAuthenticationController {
    var methodId: String?
    var session: Session?
    var user: User?

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
            parameters: .init(code: code, methodId: methodId, sessionDuration: 30)
        )
        session = response.session
        user = response.user
    }
}
```

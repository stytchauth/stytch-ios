# Swift SDK

The Swift SDK provides the easiest way for you to use Stytch on Apple platforms — wrapping the API and providing several layers of convenience on top. With just a few lines of code, you can easily authenticate your users and get back to focusing on the core of your product — all without creating extra endpoints on your backend.

## Getting Started

The Swift SDK allows you to use whatever asynchronous mechanism you prefer, be it callbacks, Async/Await, or Combine.

### Requirements

The SDK is compatible with apps targeting iOS 11.3+, macOS 10.13+, tvOS 11+.

### Installation

There are several package manager systems which are supported out of the box: Swift Package Manager, Carthage (binary only), CocoaPods. You can via further instructions [here](https://github.com/stytchauth/stytch-swift#installation).

### Configuration

To start using the StytchClient, you must configure it via one of two techniques: 1) Automatically, by including a StytchConfiguration.plist file in your main app bundle ([example](https://github.com/stytchauth/stytch-swift/blob/main/StytchDemo/Shared/StytchConfiguration.plist) or 2) Programmatically at app launch via the `StytchClient.configure(publicToken:hostUrl:)` method. You may also need to set up associated domains for your site to enable safe deeplinking between the autentication flows and your application. You can see more information and examples [here](https://github.com/stytchauth/stytch-swift/blob/b7e761794c2aae0b72517314c1b8606b107adee9/README.md#configuration).

## Documentation

You can find the [README](https://github.com/stytchauth/stytch-swift) in the Swift SDK repo and can view complete reference documentation [on GitHub pages](https://fluffy-bassoon-7f56d670.pages.github.io/documentation/stytchcore/).

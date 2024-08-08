<div align=center>

![Stytch iOS SDK](Resources/Assets/Wordmark-dark-mode.png#gh-dark-mode-only)
![Stytch iOS SDK](Resources/Assets/Wordmark-light-mode.png#gh-light-mode-only)

![Test Status](https://github.com/stytchauth/stytch-ios/actions/workflows/test.yml/badge.svg)
![iOS](https://img.shields.io/badge/iOS-13.0-blue) ![macOS](https://img.shields.io/badge/macOS-10.15-green) ![tvOS](https://img.shields.io/badge/tvOS-13.0-orange)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D)

</div>

## Introduction

[Stytch](https://stytch.com) offers a comprehensive mobile authentication solution that simplifies integration with its API using our mobile SDKs. As the only authentication provider with a complete set of APIs, Stytch enables the creation of custom end-to-end authentication flows tailored to your mobile tech stack. With two integration options, StytchCore and StytchUI, Stytch's SDKs allow you to craft an authentication experience that flexibility integrates into your app. StytchCore offers a fully customizable headless API integration to suit your specific needs, while StytchUI provides a configurable view to expedite the integration process.

Note: Currently StytchUI only supports our consumer client, B2B UI coming soon! 

## Getting Started and SDK Installation

If you are completely new to Stytch, prior to using the SDK you will first need to visit [Stytch's homepage](https://stytch.com), sign up, and create a new project in the [dashboard](https://stytch.com/dashboard/home). You'll then need to adjust your [SDK configuration](https://stytch.com/dashboard/sdk-configuration) — adding your app's bundle id to `Authorized environments` and enabling any `Auth methods` you wish to use.

Stytch uses the [Swift Package Manager](https://www.swift.org/package-manager/) for managing the distribution of our Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies. To add the Stytch SDK to your Xcode project complete the following steps.

1. Open Xcode
2. File > Add Package Dependencies
3. Enter https://github.com/stytchauth/stytch-ios
4. Choose Package Requirements (Up to next minor, up to next major, etc)
5. In your Build Settings, under `Other Linker Flags`, add `-ObjC`

## Configuration

Before using any part of the Stytch SDK, you must call configure to set the public token as specified in your project dashboard.

``` swift
import StytchCore

StytchClient.configure(publicToken: "your-public-token")
```

## Stytch Core Usage

StytchCore exposes clients for Consumer and B2B, make sure to use the one that corresponds with your project configuration. For the sake of this example we will be using the consumer one: StytchClient.

``` swift
import StytchCore

var methodId: String = ""

// Send a OTP (one time passcode) via SMS
Task {
    let parameters = StytchClient.OTP.Parameters(deliveryMethod: .sms(phoneNumber: "+12125551234"))
    let response = try await StytchClient.otps.send(parameters: parameters)
    
    // save the methodId for the subsequent authenticate call
    methodId = response.methodId
}

// Authenticate a user using the OTP sent via SMS
Task {
    let parameters = StytchClient.OTP.AuthenticateParameters(code: "123456", methodId: methodId)
    let response = try await StytchClient.otps.authenticate(parameters: parameters)
    print(response.user)
}
```

## Further Stytch Core Usage

Coming Soon!

## StytchUI Usage

Coming Soon!

## Further Reading

Full reference documentation is available for [StytchCore](https://stytchauth.github.io/stytch-ios/main/StytchCore/documentation/stytchcore/) and [StytchUI](https://stytchauth.github.io/stytch-ios/main/StytchUI/documentation/stytchui/).

## Get Help And Join The Community

Join the discussion, ask questions, and suggest new features in our ​[Slack community](https://stytch.com/docs/resources/support/overview)!

Check out the [Stytch Forum](https://forum.stytch.com/) or email us at [support@stytch.com](mailto:support@stytch.com).

## License

The Stytch iOS SDK is released under the MIT license. See [LICENSE](LICENSE) for details.

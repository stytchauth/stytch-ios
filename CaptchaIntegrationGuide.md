# Stytch Captcha Integration Guide

The Stytch iOS SDK now supports **optional** captcha integration through a separate `StytchCaptcha` package. This allows you to include Google's RecaptchaEnterprise only when needed, reducing your app's binary size when captcha functionality isn't required.

## Overview

The captcha functionality has been restructured into:

- **`StytchCore`**: Contains the `CaptchaProvider` protocol and a `NoOpCaptchaProvider` (default)
- **`StytchCaptcha`**: Contains the full `CaptchaClient` implementation with RecaptchaEnterprise

## Installation

### Option 1: Basic Usage (No Captcha)

If you don't need captcha functionality, simply use StytchCore as before:

```swift
dependencies: [
    .package(url: "https://github.com/stytchauth/stytch-ios", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "StytchCore", package: "stytch-ios")
        ]
    )
]
```

### Option 2: With Captcha Support

If you need captcha functionality, add both packages:

```swift
dependencies: [
    .package(url: "https://github.com/stytchauth/stytch-ios", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "StytchCore", package: "stytch-ios"),
            .product(name: "StytchCaptcha", package: "stytch-ios")
        ]
    )
]
```

## Usage

### Basic Setup (No Captcha)

```swift
import StytchCore

// Configure Stytch as usual
StytchClient.configure(configuration: .init(publicToken: "your-public-token"))

// The SDK will use NoOpCaptchaProvider by default - no captcha functionality
```

### Setup with Captcha Support

```swift
import StytchCore
import StytchCaptcha

// Configure Stytch
StytchClient.configure(configuration: .init(publicToken: "your-public-token"))

// Configure captcha provider
StytchClient.configureCaptcha(captchaProvider: CaptchaClient())
```

### For B2B Projects

```swift
import StytchCore
import StytchCaptcha

// Configure Stytch B2B
StytchB2BClient.configure(configuration: .init(publicToken: "your-public-token"))

// Configure captcha provider
StytchB2BClient.configureCaptcha(captchaProvider: CaptchaClient())
```

## Custom Captcha Provider

You can also implement your own captcha provider by conforming to the `CaptchaProvider` protocol:

```swift
import StytchCore

class MyCustomCaptchaProvider: CaptchaProvider {
    func setCaptchaClient(siteKey: String) async {
        // Your custom captcha setup
    }
    
    func executeRecaptcha() async -> String {
        // Your custom captcha execution
        return "your-captcha-token"
    }
    
    func isConfigured() -> Bool {
        // Return whether captcha is ready
        return true
    }
}

// Use your custom provider
StytchClient.configureCaptcha(captchaProvider: MyCustomCaptchaProvider())
```

## Migration from Previous Versions

If you were previously using Stytch with built-in captcha support:

### Before
```swift
import StytchCore

StytchClient.configure(configuration: .init(publicToken: "your-token"))
// Captcha was automatically available
```

### After (with captcha)
```swift
import StytchCore
import StytchCaptcha

StytchClient.configure(configuration: .init(publicToken: "your-token"))
StytchClient.configureCaptcha(captchaProvider: CaptchaClient())
```

### After (without captcha)
```swift
import StytchCore

StytchClient.configure(configuration: .init(publicToken: "your-token"))
// No additional setup needed - captcha is disabled by default
```
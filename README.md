# Stytch Swift SDK

## Table of contents

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
* [Getting Started](#getting-started)
  * [Configuration](#configuration)
  * [Starting UI Flow](#starting-ui-flow)
  * [Starting Custom Flow](#starting-custom-flow)


## Overview

Stytch's SDKs make it simple to seamlessly onboard, authenticate, and engage users. Improve security and user experience with passwordless authentication. The Swift SDK provides the easiest way for you to use Stytch on Apple platforms like iOS, macOS, tvOS, etc.


## Requirements

The Stytch Swift SDK requires is compatible with apps targeting the following Apple platforms: iOS 11.3+, macOS 10.13+, tvOS 11+, watchOS 4+

## Installation

### Swift Package Manager
1. Open Xcode
1. File > Add Packages
1. Enter https://github.com/stytchauth/stytch-swift
1. Choose Package Requirements (Up to next minor, up to next major, etc)

### Carthage
TBD

### CocoaPods
TBD
```
pod 'Stytch'
```

## Getting Started

### Configuration

To start using Stytch, you must configure it:

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let stytchPublicToken = "your-public-token"
    let hostUrl = URL(string: "https://your-backend.com")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        StytchClient.configure(publicToken: stytchPublicToken, hostUrl: hostUrl)
        
        return true
    }
}
```

Also you need to register your app scheme for deep link handling. Open Target -> Info tab -> URL Types, add a new one with your URL Scheme which is used in Stytch configuration.
Handle the deep link in your AppDelegate:

```swift
private func handleUrl(url: URL?) {
    guard let url = url else { return }
    
    StytchClient.handle(url: url)
}

func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    handleUrl(url: userActivity.webpageURL)
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    handleUrl(url: url)
    return true
}

func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    handleUrl(url: url)
    return true
}
```

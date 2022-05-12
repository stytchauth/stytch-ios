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

### Starting UI Flow

#### Show UI

Call StytchUI instance showUI method with  the presenter UIViewController and StytchUIDelegate.

```swift
StytchUI.shared.showUI(from: self, delegate: self)
```

#### UI Customization

You can customize prebuilt UI by setting StytchUI customization's values

StytchUICustomization
- `titleStyle: StytchTextStyle`   - Title text style
- `showTitle: Bool `- Show/hide title
- `subtitleStyle: StytchTextStyle`  - Subtitle text style
- `showSubtitle: Bool` -Show/hide subtitle
- `inputTextStyle: StytchTextStyle` - Input text style
- `inputPlaceholderStyle: StytchTextStyle` - Input placeholder text style
- `inputBackgroundColor: UIColor` - Input field background color
- `inputBorderColor: UIColor` -  Input field border color
- `inputCornerRadius: CGFloat` - Input corner radius
- `buttonTextStyle: StytchTextStyle` - Action button text style
- `buttonBackgroundColor: UIColor` - Action button background color
- `buttonCornerRadius: CGFloat` - Action button corner radius
- `showBrandLogo: Bool` - Show/hide brand logo
- `backgroundColor: UIColor` - Window background color
    
StytchTextStyle
- `font: UIFont` - Text font
- `size: CGFloat` - Text size
- `color: UIColor` - Text color

#### Handle UI callbacks

StytchUIDelegate provides callback methods:
- `onEvent` - called after a user found or new user created.
- `onSuccess` - called after successful user authorization
- `onFailure` - called when invalid configuration

```swift
extension ViewController: StytchUIDelegate {
    
    func onEvent(_ event: StytchEvent) {
        print("Event Type: \(event.type)")
        print("Is user created: \(event.created)")
        print("User ID: \(event.userId)")
    }
    
    func onSuccess(_ result: StytchResult) {
        print("Request ID: \(result.requestId)")
        print("User ID: \(result.userId)")
    }
    
    func onFailure() {
        print("Failure")
    }
}
```


### Starting Custom Flow

Set StytchDelegate and start the flow.

```swift
Stytch.shared.delegate = self
```

Call Stytch login method then the user enters the email.

```swift
Stytch.shared.login(email: textField.text)
```

#### Handle callbacks

StytchDelegate provides callback methods:
- `onSuccess` - Called after successful user authorization. Flow is finished.
- `onFailure` - Called when error occurred. Show an error message to the user.
- `onMagicLinkSent` - Called after a magic link is sent to the user email address. Update user interface.
- `onDeepLinkHandled` - Called when Stytch successfuly handles deep link and sent authorization request. Show loading for the user.

```swift
extension ViewController: StytchDelegate {
    
    func onSuccess(_ result: StytchResult) {
        print("Request ID: \(result.requestId)")
        print("User ID: \(result.userId)")
    }
    
    func onFailure(_ error: StytchError) {
        // Show error
        print("Error", error.message)
    }
    
    func onMagicLinkSent(_ email: String) {
        // Update UI
    }
    
    func onDeepLinkHandled() {
        showLoading()
    }
}
```

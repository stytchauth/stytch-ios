# Stytch iOS SDK

## Table of contents

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
* [Getting Started](#getting-started)
  * [Configuration](#configuration)
  * [Starting UI Flow](#starting-ui-flow)
  * [Starting Custom Flow](#starting-custom-flow)


## Overview

Stytch's SDKs make it simple to seamlessly onboard, authenticate, and engage users. Improve security and user experience with passwordless authentication.


## Requirements

The Stytch iOS SDK requires Xcode 12.2 or later and is compatible with apps targeting iOS 12 or above.

## Installation

### Installation with CocoaPods

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
    
    let stytchProjectID = "your-project-ID"
    let stytchSecret = "your-project-secret"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Stytch.shared.configure(projectID: stytchProjectID, secret: stytchSecret, scheme: "YOUR_APP_SCHEME", host: "stytch.com")
        
        return true
    }
}
```

You can specify Stytch environment `test` or `live`:
```
Stytch.shared.environment = .test
```

You can specify Stytch loginMethod `loginOrSignUp` (default) or `loginOrInvite`:
`loginOrSignUp`  - Send either a login or sign up magic link to the user based on if the email is associated with a user already. 
`loginOrInvite` - Send either a login or invite magic link to the user based on if the email is associated with a user already. If an invite is sent a user is not created until the token is authenticated. 
```
Stytch.shared.loginMethod = .loginOrInvite
```

Also you need to register your app scheme for deep link handling. Open Target -> Info tab -> URL Types, add a new one with your URL Scheme which is used in Stytch configuration.
Handle deep link in AppDelegate:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return Stytch.shared.handleMagicLinkUrl(userActivity.webpageURL)
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return Stytch.shared.handleMagicLinkUrl(url)
}

func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return Stytch.shared.handleMagicLinkUrl(url)
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

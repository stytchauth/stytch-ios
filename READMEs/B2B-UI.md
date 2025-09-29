# StytchB2BUI Usage
`StytchUI` creates a `StytchB2BUIClient` that offers the ability to show a configurable UI that abstracts the functionality of `StytchCore` and its B2B endpoints. You will still likely need to use the functionality embedded in `StytchCore` for retrieving the user or session, listening to observations on state change, logging the user out manually, etc. `StytchUI` can be integrated into either `UIKit` or `SwiftUI`, below are examples of both.

The UI SDK automatically handles all necessary OAuth, Email Magic Link, and Password Reset deeplinks. To enable this functionality, you need to add a specific redirect URL in your Stytch Dashboard: `stytchui-[YOUR_PUBLIC_TOKEN]://deeplink`, and set it as valid for all redirect types: Login, Signup, Invite, Reset password and Discovery.

When using `StytchUI` you must still [configure deeplinks for your application.](./Deeplinks.md)

Full reference documentation is available for [StytchCore](https://stytchauth.github.io/stytch-ios/main/StytchCore/documentation/stytchcore/) and [StytchUI](https://stytchauth.github.io/stytch-ios/main/StytchUI/documentation/stytchui/).

## SwiftUI
[SwiftUI Example For B2B](https://github.com/stytchauth/stytch-ios/blob/main/Stytch/DemoApps/StytchB2BUIDemo/ContentView.swift)

## UIKit
```swift
import StytchUI
import UIKit

func showStytchB2BUI() {
    StytchB2BUIClient.presentController(configuration: stytchB2BUIConfig, controller: self)
}

let stytchB2BUIConfig: StytchB2BUIClient.Configuration = .init(
    stytchClientConfiguration: .init(publicToken: "your-public-token", defaultSessionDuration: 5),
    products: [.emailMagicLinks, .sso, .passwords, .oauth],
    authFlowType: .organization(slug: "no-mfa"),
    //authFlowType: .discovery,
    oauthProviders: [.init(provider: .google), .init(provider: .github)]
)
```

In your `SceneDelegate` file add the following code to handle deeplinks.
```swift
import StytchUI

func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
        return
    }
    let didHandle = StytchB2BUIClient.handle(url: url)
    print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
}
```

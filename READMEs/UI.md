# StytchUI Usage
`StytchUI` creates a `StytchUIClient` that offers the ability to show a configurable UI that abstracts the functionality of `StytchCore`. You will still likely need to use the functionality embedded in `StytchCore` for retrieving the user or session, listening to observations on state change, logging the user out manually, etc. `StytchUI` can be integrated into either `UIKit` or `SwiftUI`, below are examples of both.

The UI SDK automatically handles all necessary OAuth, Email Magic Link, and Password Reset deeplinks. To enable this functionality, you need to add a specific redirect URL in your Stytch Dashboard: `stytchui-[YOUR_PUBLIC_TOKEN]://deeplink`, and set it as valid for all redirect types: Login, Signup, Invite, and Reset password.

When using `StytchUI` you must still [configure deeplinks for your application.](./Deeplinks.md)

Full reference documentation is available for [StytchCore](https://stytchauth.github.io/stytch-ios/main/StytchCore/documentation/stytchcore/) and [StytchUI](https://stytchauth.github.io/stytch-ios/main/StytchUI/documentation/stytchui/).

## SwiftUI
[SwiftUI Example For Consumer](https://github.com/stytchauth/stytch-ios/blob/main/Stytch/DemoApps/StytchUIDemo/ContentView.swift)

## UIKit
```swift
import StytchUI
import UIKit

func showStytchConsumerUI() {
    StytchUIClient.presentController(configuration: stytchConsumerUIConfig, controller: self)
}

let stytchConsumerUIConfig: StytchUIClient.Configuration = .init(
    stytchClientConfiguration: .init(publicToken: "your-public-token", defaultSessionDuration: 5),
    products: [.passwords, .emailMagicLinks, .otp, .oauth],
    oauthProviders: [.apple, .thirdParty(.google)],
    otpOptions: .init(methods: [.sms])
)
```

In your `SceneDelegate` file add the following code to handle deeplinks.
```swift
import StytchUI

func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else {
        return
    }
    let didHandle = StytchUIClient.handle(url: url)
    print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
}
```

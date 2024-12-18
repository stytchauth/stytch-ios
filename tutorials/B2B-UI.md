# StytchB2BUI Usage
`StytchUI` creates a `StytchB2BUIClient` that offers the ability to show a configurable UI that abstracts the functionality of `StytchCore`. You will still likely need to use the functionality embedded in `StytchCore` for retrieving the user or session, listening to observations on state change, logging the user out manually, etc. `StytchUI` can be integrated into either `UIKit` or `SwiftUI`, below are examples of both.

The UI SDK automatically handles all necessary OAuth, Email Magic Link, and Password Reset deeplinks. To enable this functionality, you need to add a specific redirect URL in your Stytch Dashboard: stytchui-[YOUR_PUBLIC_TOKEN]://deeplink, and set it as valid for Signups, Logins, and Password Resets.

When using `StytchUI` you must still [configure deeplinks for your application.](./Deeplinks.md)

Full reference documentation is available for [StytchCore](https://stytchauth.github.io/stytch-ios/main/StytchCore/documentation/stytchcore/) and [StytchUI](https://stytchauth.github.io/stytch-ios/main/StytchUI/documentation/stytchui/).

## UIKit
```swift
import Combine
import StytchCore
import StytchUI
import UIKit
```

In your `SceneDelegate` file add the following code to handle deeplinks.
```swift
import StytchUI
```

## SwiftUI
```swift
import Combine
import StytchCore
import StytchUI
import SwiftUI
```

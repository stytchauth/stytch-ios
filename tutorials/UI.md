# StytchUI Usage
`StytchUI` creates a `StytchUIClient` that offers the ability to show a configurable UI that abstracts the functionality of `StytchCore`. You will still likely need to use the functionality embedded in `StytchCore` for retrieving the user or session, listening to observations on state change, logging the user out manually, etc. `StytchUI` can be integrated into either `UIKit` or `SwiftUI`, below are examples of both.

When using `StytchUI` you must still [configure deeplinks for your application.](./Deeplinks.md)

Full reference documentation is available for [StytchCore](https://stytchauth.github.io/stytch-ios/main/StytchCore/documentation/stytchcore/) and [StytchUI](https://stytchauth.github.io/stytch-ios/main/StytchUI/documentation/stytchui/).

## UIKit
```swift
import Combine
import StytchCore
import StytchUI
import UIKit

class ViewController: UIViewController {
    var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StytchUIClient.configure(publicToken: "public-token", config: stytchUIConfig)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showStytchUI()
    }
    
    func showStytchUI() {
        guard isAuthenticated == false else {
            return
        }
        
        StytchUIClient.presentController(controller: self) { authenticateResponseType in
            print("user: \(authenticateResponseType.user) - session: \(authenticateResponseType.session)")
            DispatchQueue.main.async {
                // Show confirmation of authentication
            }
        }
    }
    
    var isAuthenticated: Bool {
        if StytchClient.sessions.session != nil, StytchClient.user.getSync() != nil {
            return true
        } else {
            return false
        }
    }
    
    let stytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            oauth: .init(
                providers: [.apple, .thirdParty(.google)],
                loginRedirectUrl: .init(string: "stytch-ui://login")!,
                signupRedirectUrl: .init(string: "stytch-ui://signup")!
            ),
            password: .init(),
            magicLink: .init(),
            otp: .init(methods: [.sms])
        )
    )
}
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

## SwiftUI
```swift
import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    @State private var shouldPresentAuth = false
    @State var subscriptions: Set<AnyCancellable> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("You have logged in with Stytch!")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
            }
            .padding()
            .authenticationSheet(isPresented: $shouldPresentAuth, onAuthCallback: { authenticateResponseType in
                print("user: \(authenticateResponseType.user) - session: \(authenticateResponseType.session)")
            }).onOpenURL { url in
                let didHandle = StytchUIClient.handle(url: url)
                print("StytchUIClient didHandle: \(didHandle) - url: \(url)")
            }
        }.task {
            StytchUIClient.configure(publicToken: "public-token", config: stytchUIConfig)
            setUpObservations()
        }
    }

    func setUpObservations() {
        StytchClient.isInitialized.sink { isInitialized in
            shouldPresentAuth = !isAuthenticated
        }.store(in: &subscriptions)

        StytchClient.sessions.onAuthChange.sink { token in
            shouldPresentAuth = !isAuthenticated
        }.store(in: &subscriptions)
    }
    
    var isAuthenticated: Bool {
        if StytchClient.sessions.session != nil, StytchClient.user.getSync() != nil {
            return true
        } else {
            return false
        }
    }
    
    let stytchUIConfig: StytchUIClient.Configuration = .init(
        products: .init(
            oauth: .init(
                providers: [.apple, .thirdParty(.google)],
                loginRedirectUrl: .init(string: "stytch-ui://login")!,
                signupRedirectUrl: .init(string: "stytch-ui://signup")!
            ),
            password: .init(),
            magicLink: .init(),
            otp: .init(methods: [.sms])
        )
    )
}

#Preview {
    ContentView()
}
```

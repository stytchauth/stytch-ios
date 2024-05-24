import Combine
import StytchCore
import StytchUI
import SwiftUI

struct ContentView: View {
    var config: StytchUIClient.Configuration
    @State private var authPresented = false
    @State private var sessionAndUser: (Session, User)?
    @State private var cancellable: AnyCancellable? = nil

    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
            .authenticationSheet(
                isPresented: $authPresented,
                config: config
            )
        }.task {
            // If you dont have a StytchConfiguration.plist you need to call configure here
            // StytchClient.configure(publicToken: "public-token")

            cancellable = StytchClient.isInitialized.sink { result in
                let session = StytchClient.sessions.session
                let user = StytchClient.user.getSync()
                if let session, let user {
                    sessionAndUser = (session, user)
                    authPresented = false
                } else {
                    authPresented = true
                    print("no session and user tuple")
                }
                print("isInitialized: \(result)")
            }
        }
    }
}

#Preview {
    ContentView(config: .realisticStytchUIConfig)
}

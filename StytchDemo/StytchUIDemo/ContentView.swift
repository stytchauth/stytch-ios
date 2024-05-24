import StytchUI
import SwiftUI
import StytchCore
import Combine

struct ContentView: View {
    @State private var authPresented = true
    var config: StytchUIClient.Configuration
    
    @State private var sessionAndUser: (Session, User)?
    @State private var cancellable: AnyCancellable? = nil
    @State private var isInitialized: Bool = false

    var body: some View {
        let someView = VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        
        NavigationView {
            if isInitialized {
                if let sessionAndUser = sessionAndUser {
                    someView
                } else {
                    someView
                    .authenticationSheet(
                        isPresented: $authPresented,
                        config: config
                    )
                }
            }
        }.task {
            cancellable = StytchClient.isInitialized.sink { result in
                let session = StytchClient.sessions.session
                let user = StytchClient.user.getSync()
                if let session, let user {
                    sessionAndUser = (session, user)
                } else {
                    print("no session and user tuple")
                }
                isInitialized = result
            }
        }
    }
}

#Preview {
    ContentView(config: .realisticStytchUIConfig)
}

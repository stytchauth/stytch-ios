import StytchCore
import SwiftUI

struct ContentView: View {
    let hostUrl: URL
    var session: Session?
    let logOutTapped: () -> Void
    let onAuth: (Session) -> Void

    var body: some View {
        if let session = session {
            VStack {
                SessionView(session: session, hostUrl: hostUrl)
                Button("Log out") {
                    self.logOutTapped()
                }
                .buttonStyle(.bordered)
            }
        } else {
            SMSLoginView(hostUrl: hostUrl, onAuth: onAuth)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next force_unwrapping
        ContentView(hostUrl: URL(string: "https://stytch.com")!, session: nil) {} onAuth: { _ in }
    }
}

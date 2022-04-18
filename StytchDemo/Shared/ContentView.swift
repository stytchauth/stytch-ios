import StytchCore
import SwiftUI

struct ContentView: View {
    let hostUrl: URL
    var session: Session?

    var body: some View {
        if let session = session {
            SessionView(session: session)
        } else {
            LoginView(hostUrl: hostUrl)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next force_unwrapping
        ContentView(hostUrl: URL(string: "https://stytch.com")!, session: nil)
    }
}

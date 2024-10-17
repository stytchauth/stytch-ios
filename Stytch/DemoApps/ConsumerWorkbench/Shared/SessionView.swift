import StytchCore
import SwiftUI

struct SessionView: View {
    let sessionUser: (session: Session, user: User)
    private var session: Session { sessionUser.session }

    var body: some View {
        VStack(alignment: .leading) {
            #if os(macOS)
            Text("Hi, \(sessionUser.user.name.firstName.presence ?? "pal")!")
                .font(.title)
                .padding()
            #endif
            Text("User ID: " + session.userId.rawValue)
            Text("Session ID: " + session.sessionId.rawValue)
            Text("Started at: " + session.startedAt.formatted(date: .abbreviated, time: .shortened))
            Text("Expires at: " + session.expiresAt.formatted(date: .abbreviated, time: .shortened))
            Text("User agent: " + (session.attributes.userAgent.presence ?? "N/A"))
            Text("Factors:").bold()
            Text(session.factorsDescription)
                .padding([.leading], 8)
        }
        .navigationTitle("Hi, \(sessionUser.user.name.firstName.presence ?? "pal")!")
    }
}

extension AuthenticationFactor {
    var description: String {
        """
        Factor delivery method: \(deliveryMethod ?? "N/A")
        Factor type: \(kind)
        Factor contact info: \(emailAddress ?? phoneNumber ?? "N/A")
        Last authenticated: ") + Text(factor.lastAuthenticatedAt, format: .dateTime)
        """
    }
}

extension Session {
    var factorsDescription: String {
        var returnString = ""
        for factor in authenticationFactors {
            returnString = returnString + factor.description + "\n"
        }
        return returnString
    }
}

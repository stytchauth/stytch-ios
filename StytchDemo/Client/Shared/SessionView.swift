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
            Text("User ID: " + session.userId)
            Text("Session ID: " + session.sessionId)
            Text("Started at: " + session.startedAt.formatted(date: .abbreviated, time: .shortened))
            Text("Expires at: " + session.expiresAt.formatted(date: .abbreviated, time: .shortened))
            Text("User agent: " + (session.attributes.userAgent.presence ?? "N/A"))
            Text("Factors:").bold()
            ForEach(session.authenticationFactors, id: \.self) { factor in
                Text("Factor delivery method: \(factor.deliveryMethod ?? "N/A")")
                Text("Factor type: \(factor.kind)")
                Text("Factor contact info: \(factor.emailAddress ?? factor.phoneNumber ?? "N/A")")
                Text("Last authenticated: ") + Text(factor.lastAuthenticatedAt, format: .dateTime)
            }
            .padding([.leading], 8)
        }
        .navigationTitle("Hi, \(sessionUser.user.name.firstName.presence ?? "pal")!")
    }
}

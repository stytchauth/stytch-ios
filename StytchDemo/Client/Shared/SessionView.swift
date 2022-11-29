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
            Text("Factors:").bold()
            ForEach(session.authenticationFactors, id: \.self) { factor in
                Text("Factor type: \(factor.kind)")
                Text("Factor detail: \(factor.emailAddress ?? factor.phoneNumber ?? "unknown")")
                Text(factor.lastAuthenticatedAt.description)
            }
            .padding([.leading], 8)
            Text("Session ID: " + session.sessionId)
            Text("Started at: " + session.startedAt.formatted(date: .abbreviated, time: .shortened))
            Text("Expires at: " + session.expiresAt.formatted(date: .abbreviated, time: .shortened))
            Text("User agent: " + session.attributes.userAgent)
        }.navigationTitle("Hi, \(sessionUser.user.name.firstName.presence ?? "pal")!")
            .task {
                print(session.authenticationFactors.map(\.rawData))
            }
    }
}

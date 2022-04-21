import StytchCore
import SwiftUI

struct SessionView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading) {
            Text("User ID: " + session.userId)
            ForEach(session.authenticationFactors, id: \.lastAuthenticatedAt) { factor in
                if case let .email(email) = factor.deliveryMethod {
                    Text("Factor type: email")
                    Text("Factor ID: \(email.emailId)")
                    Text(email.emailAddress)
                }
            }
            Text("Session ID: " + session.sessionId)
            Text("Started at: " + session.startedAt.formatted(date: .abbreviated, time: .shortened))
            Text("Expires at: " + session.expiresAt.formatted(date: .abbreviated, time: .shortened))
            Text("User agent: " + session.attributes.userAgent)
        }
    }
}

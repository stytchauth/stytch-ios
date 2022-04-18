import SwiftUI

struct ContentView: View {
    let hostUrl: URL
    var session: Session?

    var body: some View {
        if let session = session {
            SessionView(session: session)
        } else {
            HostView(hostUrl: hostUrl)
        }
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

struct SessionView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading) {
            Text("User ID: " + session.userId)
            Text("Session ID: " + session.sessionId)
            Text("Started at: " + session.startedAt.formatted(date: .abbreviated, time: .shortened))
            Text("Expires at: " + session.expiresAt.formatted(date: .abbreviated, time: .shortened))
            Text("User agent: " + session.attributes.userAgent)
            ForEach(session.authenticationFactors, id: \.lastAuthenticatedAt) { factor in
                if case let .email(email) = factor.deliveryMethod {
                    Text("Factor type: email")
                    Text("Factor ID: \(email.emailId)")
                    Text(email.emailAddress)
                }
            }
        }
    }
}

struct HostView: View {
    let hostUrl: URL

    @State private var email: String = ""

    var body: some View {
        VStack {
            TextField(text: $email, label: { Text("Email") })
                .textContentType(.emailAddress)
                .autocapitalization(.no)
                .disableAutocorrection(true)

            Button(action: {
                Task {
                    let emailParams: EmailParameters = .init(
                        email: .init(rawValue: email),
                        loginMagicLinkUrl: hostUrl.appendingPathComponent("login"),
                        signupMagicLinkUrl: hostUrl.appendingPathComponent("signup"),
                        loginExpiration: .init(rawValue: 30),
                        signupExpiration: .init(rawValue: 30)
                    )
                    do {
                        _ = try await StytchClient.magicLinks.email.loginOrCreate(parameters: emailParams)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Log in")
            })
        }
    }
}

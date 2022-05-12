import StytchCore
import SwiftUI

struct SessionView: View {
    let session: Session
    let hostUrl: URL

    var body: some View {
        VStack(alignment: .leading) {
            Text("User ID: " + session.userId)
            ForEach(session.authenticationFactors, id: \.lastAuthenticatedAt) { factor in
                switch factor.deliveryMethod {
                case let .email(email):
                    Text("Factor type: email")
                    Text("Factor ID: \(email.emailId)")
                    Text(email.emailAddress)
                case let .sms(sms):
                    Text("Factor type: email")
                    Text("Factor ID: \(sms.phoneId)")
                    Text(sms.phoneNumber)
                default:
                    EmptyView()
                }
            }
            Text("Session ID: " + session.sessionId)
            Text("Started at: " + session.startedAt.formatted(date: .abbreviated, time: .shortened))
            Text("Expires at: " + session.expiresAt.formatted(date: .abbreviated, time: .shortened))
            Text("User agent: " + session.attributes.userAgent)
            HStack {
                Spacer()
                Button("Fetch host url index", action: {
                    var request: URLRequest = .init(url: hostUrl)
                    StytchClient.sessions.sessionToken.map { request.addValue($0.value, forHTTPHeaderField: "X-Stytch-Token") }

                    let task = URLSession.shared.dataTask(
                        with: request,
                        completionHandler: { data, _, _ in
                            print(data.flatMap { String(data: $0, encoding: .utf8) } ?? "no data")
                        }
                    )

                    print("Request: ", request)
                    print("Original request headers: ", task.originalRequest?.allHTTPHeaderFields ?? [])
                    Task {
                        print("Cookies for task: ", await HTTPCookieStorage.shared.cookies(for: task) ?? [])
                    }

                    task.resume()
                })
                .buttonStyle(.borderedProminent)
                Spacer()
            }
        }
    }
}

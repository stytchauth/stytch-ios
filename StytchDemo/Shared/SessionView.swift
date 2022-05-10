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
            Button("Fetch index", action: {
                var request: URLRequest = .init(url: URL(string: "https://dan-stytch.github.io")!)
                StytchClient.sessions.sessionToken.map { request.addValue($0, forHTTPHeaderField: "X-Stytch-Token") }

                let task = URLSession.shared.dataTask(
                    with: request,
                    completionHandler: { data, _, _ in
                        print(data.flatMap { String(data: $0, encoding: .utf8) } ?? "no data")
                    }
                )

                print("Request: ", request)
                print("Original request headers: ", task.originalRequest?.allHTTPHeaderFields ?? [])
                print("Cookies for url: ", HTTPCookieStorage.shared.cookies(for: request.url!) ?? [])
                Task {
                    print("Cookies for task: ", await HTTPCookieStorage.shared.cookies(for: task) ?? [])
                }

                task.resume()
            })
        }
    }
}

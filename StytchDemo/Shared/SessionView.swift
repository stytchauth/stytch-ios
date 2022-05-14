import StytchCore
import SwiftUI

struct SessionView: View {
    let session: Session
    let hostUrl: URL

    var body: some View {
        VStack(alignment: .leading) {
            Text("User ID: " + session.userId)
            Text("Factors:").bold()
            ForEach(session.authenticationFactors, id: \.lastAuthenticatedAt) { factor in
                Text("Factor type: \(factor.deliveryMethod.factorType)")
                Text("Factor ID: \(factor.deliveryMethod.factorId)")
                Text(factor.deliveryMethod.factorValue)
            }
            .padding([.leading], 8)
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

private extension Session.AuthenticationFactor.DeliveryMethod {
    var factorType: String {
        switch self {
        case .authenticatorApp:
            return "Authenticator App"
        case .recoveryCode:
            return "Recovery Code"
        case .email:
            return "Email"
        case .sms:
            return "SMS"
        case .whatsapp:
            return "WhatsApp"
        case .oauthGoogle:
            return "OauthGoogle"
        case .oauthApple:
            return "OauthApple"
        case .oauthGithub:
            return "OauthGithub"
        case .oauthMicrosoft:
            return "OauthMicrosoft"
        case .webauthnRegistration:
            return "WebAuthN"
        }
    }

    var factorId: String {
        switch self {
        case let .authenticatorApp(value):
            return value.totpId
        case let .recoveryCode(value):
            return value.totpRecoveryCodeId
        case let .email(value):
            return value.emailId
        case let .sms(value), let .whatsapp(value):
            return value.phoneId
        case let .oauthGoogle(value):
            return value.id
        case let .oauthApple(value):
            return value.id
        case let .oauthGithub(value):
            return value.id
        case let .oauthMicrosoft(value):
            return value.id
        case let .webauthnRegistration(value):
            return value.webauthnRegistrationId
        }
    }

    var factorValue: String {
        switch self {
        case .authenticatorApp:
            return "THE CODE"
        case .recoveryCode:
            return "THE CODE"
        case let .email(value):
            return value.emailAddress
        case let .sms(value), let .whatsapp(value):
            return value.phoneNumber
        case let .oauthGoogle(value):
            return value.providerSubject
        case let .oauthApple(value):
            return value.providerSubject
        case let .oauthGithub(value):
            return value.providerSubject
        case let .oauthMicrosoft(value):
            return value.providerSubject
        case let .webauthnRegistration(value):
            return value.domain.absoluteString
        }
    }
}

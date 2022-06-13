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
        }.navigationTitle("Hi, \(sessionUser.user.name.firstName.presence ?? "pal")!")
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

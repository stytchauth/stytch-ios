import SwiftUI

struct StytchUI_Previews: PreviewProvider {
    static var previews: some View {
        AuthRootViewController(
            config: .init(
                stytchClientConfiguration: .init(publicToken: "", defaultSessionDuration: 5),
                products: [.oauth, .emailMagicLinks, .otp],
                oauthProviders: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                otpOptions: .init(methods: [.sms, .email, .whatsapp])
            )
        )
        .toControllerView()
        .previewDisplayName("Root")

        EmailConfirmationViewController(
            state: .forgotPassword(
                config: .init(
                    stytchClientConfiguration: .init(publicToken: "", defaultSessionDuration: 5),
                    products: [.oauth, .emailMagicLinks, .otp],
                    oauthProviders: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                    otpOptions: .init(methods: [.sms, .email, .whatsapp])
                ),
                email: "dan@stytch.com"
            ) {}
        )
        .inNavigationController()
        .toControllerView()
        .previewDisplayName("AIVC")

        PasswordViewController(
            state: .init(
                config: .init(
                    stytchClientConfiguration: .init(publicToken: "", defaultSessionDuration: 5),
                    products: [.oauth, .emailMagicLinks, .otp],
                    oauthProviders: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                    otpOptions: .init(methods: [.sms, .email, .whatsapp])
                ),
                intent: .enterNewPassword(token: ""),
                email: "dan.loman@gmail.com",
                magicLinksEnabled: false
            )
        )
        .inNavigationController()
        .toControllerView()
        .previewDisplayName("PW")

        OTPCodeViewController(
            state: .init(
                config: .init(
                    stytchClientConfiguration: .init(publicToken: "", defaultSessionDuration: 5),
                    products: [.oauth, .emailMagicLinks, .otp],
                    oauthProviders: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                    otpOptions: .init(methods: [.sms, .email, .whatsapp])
                ),
                otpMethod: .sms,
                input: "888-888-8888",
                formattedInput: "(888) 888-8888",
                methodId: "",
                codeExpiry: .init().advanced(by: 120),
                passwordsEnabled: true
            )
        )
        .inNavigationController()
        .toControllerView()
        .previewDisplayName("OTP")
    }
}

struct ControllerView: UIViewControllerRepresentable {
    private let controller: UIViewController

    init(_ controller: UIViewController) {
        self.controller = controller
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        controller
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

extension UIViewController {
    func toControllerView() -> ControllerView {
        .init(self)
    }

    func inNavigationController() -> UIViewController {
        UINavigationController(rootViewController: self)
    }
}

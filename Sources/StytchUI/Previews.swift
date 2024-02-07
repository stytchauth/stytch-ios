import SwiftUI

// swiftlint:disable force_unwrapping
struct StytchUI_Previews: PreviewProvider {
    static var previews: some View {
        AuthRootViewController(
            config: .init(
                publicToken: "",
                products: .init(
                    oauth: .init(
                        providers: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                        loginRedirectUrl: .init(string: "stytch-auth://login")!,
                        signupRedirectUrl: .init(string: "stytch-auth://signup")!
                    ),
                    magicLink: .init(),
                    otp: .init(methods: [.sms, .email, .whatsapp])
                ),
                session: .init()
            )
        )
        .toControllerView()
        .previewDisplayName("Root")

        ActionableInfoViewController(
            state: .forgotPassword(
                config: .init(
                    publicToken: "",
                    products: .init(
                        oauth: .init(
                            providers: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                            loginRedirectUrl: .init(string: "stytch-auth://login")!,
                            signupRedirectUrl: .init(string: "stytch-auth://signup")!
                        ),
                        magicLink: .init(),
                        otp: .init(methods: [.sms, .email, .whatsapp])
                    ),
                    session: .init()
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
                    publicToken: "",
                    products: .init(
                        oauth: .init(
                            providers: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                            loginRedirectUrl: .init(string: "stytch-auth://login")!,
                            signupRedirectUrl: .init(string: "stytch-auth://signup")!
                        ),
                        magicLink: .init(),
                        otp: .init(methods: [.sms, .email, .whatsapp])
                    ),
                    session: .init()
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
                    publicToken: "",
                    products: .init(
                        oauth: .init(
                            providers: [.apple, .thirdParty(.google), .thirdParty(.twitter)],
                            loginRedirectUrl: .init(string: "stytch-auth://login")!,
                            signupRedirectUrl: .init(string: "stytch-auth://signup")!
                        ),
                        magicLink: .init(),
                        otp: .init(methods: [.sms, .email, .whatsapp])
                    ),
                    session: .init()
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

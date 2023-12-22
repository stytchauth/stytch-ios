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
                    sms: .init()
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
                        sms: .init()
                    ),
                    session: .init()
                ),
                email: "dan@stytch.com",
                retryAction: {}
            ),
            navController: UINavigationController()
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
                        sms: .init()
                    ),
                    session: .init()
                ),
                intent: .enterNewPassword(token: ""),
                email: "dan.loman@gmail.com",
                magicLinksEnabled: false
            ),
            navController: UINavigationController()
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
                        sms: .init()
                    ),
                    session: .init()
                ),
                phoneNumberE164: "888-888-8888",
                formattedPhoneNumber: "(888) 888-8888",
                methodId: "",
                codeExpiry: .init().advanced(by: 120)
            ),
            navController: UINavigationController()
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

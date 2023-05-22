import SwiftUI

struct StytchUI_Previews: PreviewProvider {
    static var previews: some View {
        AuthRootViewController(
            config: .init(
                publicToken: "",
                oauth: .init(providers: [.thirdParty(.google), .apple, .thirdParty(.coinbase)]),
                input: .magicLinkAndPassword(sms: true)
            )
        )
        .toControllerView()
        .previewDisplayName("Root")


        ActionableInfoViewController(
            state: .forgotPassword(email: "dan@stytch.com")

        ) { .actionableInfo($0) }
            .inNavigationController()
            .toControllerView()
            .previewDisplayName("AIVC")

        PasswordViewController(
            state: .init(
                intent: .enterNewPassword,
                email: "dan.loman@gmail.com",
                magicLinksEnabled: false
            )
        ) { .password($0) }
            .inNavigationController()
            .toControllerView()
            .previewDisplayName("PW")

        OTPCodeViewController(
            state: .init(
                phoneNumberE164: "888-888-8888",
                formattedPhoneNumber: "(888) 888-8888",
                methodId: "",
                codeExpiry: .init().advanced(by: 120)
            )
        ) { .otp($0) }
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

    func makeUIViewController(context: Context) -> UIViewController {
        controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension UIViewController {
    func toControllerView() -> ControllerView {
        .init(self)
    }

    func inNavigationController() -> UIViewController {
        UINavigationController(rootViewController: self)
    }
}

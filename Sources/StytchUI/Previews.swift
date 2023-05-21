import SwiftUI

struct StytchUI_Previews: PreviewProvider {
    static var previews: some View {
        AuthRootViewController(
            config: .init(
                oauth: .init(providers: [.thirdParty(.google), .apple]),
                input: .magicLink(sms: true)
            )
        )
        .toControllerView()
        .previewDisplayName("Root")


        ActionableInformationViewController(
            state: .forgotPassword(email: "dan@stytch.com")

        ) { .oauth($0) }
            .inNavigationController()
            .toControllerView()
            .previewDisplayName("AIVC")

        if #available(iOS 15, *) {
            PasswordViewController(
                state: .init(
                    intent: .signup,
                    email: "dan.loman@gmail.com",
                    magicLinksEnabled: true
                )
            ) { _ in .oauth(.didTap(provider: .apple)) }
            //            state: .loaded(
            //                .forgotPassword(email: "dan@stytch.com")
            //            )
            //        ) { .oauth($0) }
                .inNavigationController()
                .toControllerView()
                .previewDisplayName("PW")
        }
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

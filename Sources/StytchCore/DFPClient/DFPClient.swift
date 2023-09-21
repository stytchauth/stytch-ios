#if os(iOS)
import Foundation
import UIKit
import WebKit

internal protocol DFPProvider {
    func getTelemetryId(publicToken: String) async -> String
}

final class DFPClient : DFPProvider {
    func getTelemetryId(publicToken: String) async -> String {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                Task {
                    if let topViewController = UIApplication.shared.topMostViewController {
                        guard let dfpFileUrl = Bundle.module.url(forResource: "dfp", withExtension: "html") else {
                            continuation.resume(returning: "Unable to load DFP file")
                            return
                        }
                        let messageHandler = MessageHandler(continuation: continuation)
                        let userScript = WKUserScript(source: "fetchTelemetryId('\(publicToken)')", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                        let userContentController = WKUserContentController()
                        userContentController.addUserScript(userScript)
                        userContentController.add(messageHandler, name: "StytchDFP")
                        let configuration = WKWebViewConfiguration()
                        configuration.userContentController = userContentController
                        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
                        topViewController.view.addSubview(webView)
                        webView.loadFileURL(dfpFileUrl, allowingReadAccessTo: dfpFileUrl)
                    } else {
                        continuation.resume(returning: "unable to inject telemetry webview")
                    }
                }
            }
        }
    }
}

private final class MessageHandler: NSObject, WKScriptMessageHandler {
    var continuation: CheckedContinuation<String, Never>

    init(continuation: CheckedContinuation<String, Never>) {
        self.continuation = continuation
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        continuation.resume(returning: message.body as? String ?? "")
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }

        return self
    }
}

private extension UIApplication {
    var topMostViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
#endif

#if os(iOS)
import Foundation
import UIKit
import WebKit

internal protocol DFPProvider {
    func getTelemetryId(publicToken: String) async -> String
}

final actor DFPClient: DFPProvider {
    func getTelemetryId(publicToken: String) async -> String {
        guard let dfpFileUrl = getResource(myBundle: Bundle(for: Self.self), name: "dfp", ext: "html") else {
            return "Unable to load DFP file"
        }
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                if let topViewController = UIApplication.shared.topMostViewController {
                    let messageHandler = MessageHandler()
                    messageHandler.addContinuation(continuation)
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

private final class MessageHandler: NSObject, WKScriptMessageHandler {
    var continuations: [CheckedContinuation<String, Never>] = []

    func addContinuation(_ continuation: CheckedContinuation<String, Never>) {
        continuations.append(continuation)
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        continuations.forEach { $0.resume(returning: message.body as? String ?? "") }
        continuations.removeAll()
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

private func getResource(myBundle: Bundle, name: String, ext: String) -> URL? {
    #if SWIFT_PACKAGE
    return Bundle.module.url(forResource: name, withExtension: ext)
    #else
    guard let resourceBundleURL = myBundle.url(forResource: "StytchCore", withExtension: "bundle") else {
        return nil
    }
    guard let resourceBundle = Bundle(url: resourceBundleURL) else {
        return nil
    }
    return resourceBundle.url(forResource: name, withExtension: ext)
    #endif
}
#endif

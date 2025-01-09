#if os(iOS)
import Foundation
import UIKit
import WebKit

internal protocol DFPProvider {
    func getTelemetryId(publicToken: String, dfppaDomain: String) async -> String
}

final class DFPClient: DFPProvider, Sendable {
    private let messageHandler = MessageHandler()

    func getTelemetryId(publicToken: String, dfppaDomain: String) async -> String {
        guard let dfpFileUrl = getResource(myBundle: Bundle(for: Self.self), name: "dfp", ext: "html") else {
            return "Unable to load DFP file"
        }
        return await withCheckedContinuation { [weak self] continuation in
            DispatchQueue.main.async {
                if let rootViewController = UIApplication.shared.rootViewController {
                    self?.messageHandler.addContinuation(continuation)

                    let userScript = WKUserScript(source: "fetchTelemetryId('\(publicToken)', 'https://\(dfppaDomain)/submit');", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                    let userContentController = WKUserContentController()

                    userContentController.addUserScript(userScript)
                    if let messageHandler = self?.messageHandler {
                        userContentController.add(messageHandler, name: "StytchDFP")
                    }

                    let configuration = WKWebViewConfiguration()
                    configuration.userContentController = userContentController

                    let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
                    self?.messageHandler.addWebView(webView)

                    rootViewController.view.addSubview(webView)
                    webView.loadFileURL(dfpFileUrl, allowingReadAccessTo: dfpFileUrl)
                } else {
                    continuation.resume(returning: "unable to inject telemetry webview")
                }
            }
        }
    }
}

private final class MessageHandler: NSObject, WKScriptMessageHandler, Sendable {
    var continuations: [CheckedContinuation<String, Never>] = []
    var webviews: [WKWebView] = []

    func addContinuation(_ continuation: CheckedContinuation<String, Never>) {
        continuations.append(continuation)
    }

    func addWebView(_ webview: WKWebView) {
        webviews.append(webview)
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        continuations.forEach { $0.resume(returning: message.body as? String ?? "") }
        continuations.removeAll()
        webviews.forEach { $0.removeFromSuperview() }
        webviews.removeAll()
    }
}

private extension UIApplication {
    var rootViewController: UIViewController? {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
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

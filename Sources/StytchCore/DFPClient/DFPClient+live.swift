import Foundation
import UIKit
import WebKit

final class MessageHandler : NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
    }
}

extension DFPClient {
    static let live: Self = .init(
        getTelemetryId: {
            guard let publicToken = StytchClient.instance.configuration?.publicToken else { throw StytchError.clientNotConfigured }
            DispatchQueue.main.async {
                Task {
                    do {
                        if let topViewController = UIApplication.shared.topMostViewController {
                            let webConfiguration = WKWebViewConfiguration()
                            let messageHandler = MessageHandler()
                            let dfpFileUrl = Bundle.module.url(forResource: "dfp", withExtension: "html")!
                            let userScript = WKUserScript(source: "fetchTelemetryId('\(publicToken)')", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                            let userContentController = WKUserContentController()
                            userContentController.addUserScript(userScript)
                            userContentController.add(messageHandler, name: "StytchDFP")
                            let configuration = WKWebViewConfiguration()
                            configuration.userContentController = userContentController
                            let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
                            topViewController.view.addSubview(webView)
                            webView.loadFileURL(dfpFileUrl, allowingReadAccessTo: dfpFileUrl)
                        }
                    }
                }
            }
            return ""
        }
    )
}

extension UIViewController {
  var topMostViewController : UIViewController {

    if let presented = self.presentedViewController {
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

extension UIApplication {
  var topMostViewController : UIViewController? {
      let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
      if var topController = keyWindow?.rootViewController {
          while let presentedViewController = topController.presentedViewController {
              topController = presentedViewController
          }
          return topController
      }
      return nil
  }
}

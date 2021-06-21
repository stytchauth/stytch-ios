//
//  AppDelegate.swift
//  StytchExample
//
//  Created by Edgar Kroman on 2020-12-04.
//

import UIKit
import Stytch

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    let stytchProjectID = "project-test-ac70ffe6-4e3b-45ca-b874-c6171ddb89df"
    let stytchSecretKey = "secret-test-ruIeuu_RLEfPNWJNwaLDLFAdz-2_F3vyNoY="


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        StytchMagicLink.shared.configure(projectID: stytchProjectID, secret: stytchSecretKey, scheme: "stytchapp", host: "stytch.com")
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        StytchMagicLink.shared.environment = .test
        StytchMagicLink.shared.createUserAsPending = true
        StytchMagicLink.shared.delegate = self
        let initialViewController = StytchMagicLinkUI.shared.loginViewController()

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return StytchMagicLink.shared.handleMagicLinkUrl(userActivity.webpageURL)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return StytchMagicLink.shared.handleMagicLinkUrl(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return StytchMagicLink.shared.handleMagicLinkUrl(url)
    }

}

extension AppDelegate: StytchMagicLinkDelegate {
    func onSuccess(_ result: StytchResult){
        let authedVC = AuthedViewController()

        self.window?.rootViewController = authedVC
        self.window?.makeKeyAndVisible()
        print("@Ethan SUCCESS")
    }
    
    func onFailure(_ error: StytchError){
        //Handle failure
        print("@Ethan failure")
    }
}


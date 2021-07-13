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
    
    let liveStytchProjectID = "project-live-4d957d53-b033-4cdd-8b59-c3a36e566be8"

    let testStytchProjectID = "project-test-ac70ffe6-4e3b-45ca-b874-c6171ddb89df:secret-test-ruIeuu_RLEfPNWJNwaLDLFAdz-2_F3vyNoY=" // "project-test-ac70ffe6-4e3b-45ca-b874-c6171ddb89df"//




    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        launchMagicLink()
        
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true//Stytch.shared.magicLink.handleMagicLinkUrl(userActivity.webpageURL)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true//Stytch.shared.magicLink.handleMagicLinkUrl(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return true//Stytch.shared.magicLink.handleMagicLinkUrl(url)
    }

    func launchMagicLink(){
        Stytch.shared.configure(projectID: testStytchProjectID, universalLink: URL(string: "https://test.com")!)
        self.window = UIWindow(frame: UIScreen.main.bounds)

        Stytch.shared.environment = .test
       // StytchMagicLink.shared.delegate = self

        StytchSMSUI.shared.delegate = self
        let initialViewController = StytchMagicLinkUI.shared.loginViewController()

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
    func launchSMS(){
        Stytch.shared.configure(projectID: testStytchProjectID)
        self.window = UIWindow(frame: UIScreen.main.bounds)

        Stytch.shared.otp.environment = .test
        Stytch.shared.otp.otpAuthenticator = ExampleOTPAuthenticator()
       // StytchMagicLink.shared.delegate = self
        StytchSMSUI.shared.delegate = self
        StytchSMSUI.shared.customization
        let initialViewController = StytchSMSUI.shared.loginViewController()

        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }

}

extension AppDelegate: StytchSMSUIDelegate {
    func onSuccess(_ result: StytchResult){
        let authedVC = AuthedViewController()

        self.window?.rootViewController = authedVC
        self.window?.makeKeyAndVisible()
        print("SUCCESS")
    }
    
    func onFailure(_ error: StytchError){
        //Handle failure
        print("Failure")
    }
}


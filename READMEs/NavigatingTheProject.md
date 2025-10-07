# Navigating the Project and Running the Sample Apps

## 1. Opening The Project
To open the project you must first open the project file located at: `stytch-ios/Stytch/Stytch.xcodeproj`

## 2. Navigating The Project
The repository has 2 top level directories within the project. 
* **DemoApps/**: All example code to help you get started and to help us test the SDK.
* **Stytch/**: The source code for the Stytch iOS SDK.

<sub>(Note. The directory structure in the file system does not exactly mirror the directory structure in the Xcode project)</sub>

## 3. Understanding the Sample Apps
The sample apps are broken down into 2 categories, workbench apps and demo apps.
* The workbench apps are testing apps, intended for internal development purposes. Almost all user flows are implemented in these apps, for reference and testing, but do not necessarily represent best practices or realistic usage.
* The demo apps are intended for demonstrating realistic use cases of the Stytch SDK, using both the Headless and Pre-Built UI implementations. Feel free to copy these projects and edit them to suit your needs

## 4. Configuring the Sample Apps
For each app you would like to run you must first ensure you have added your [public token](https://stytch.com/dashboard) to the code and have added the app’s bundle id to your project dashboard's [SDK configuration](https://stytch.com/dashboard/sdk-configuration), click "edit" for the "Authorized applications (Required)" section, add your bundle id under "Bundle & application IDs" and make sure to click "save".

* **StytchDemo**    
Bundle ID: `com.stytch.StytchDemo`  
[Configure the public token](../Stytch/DemoApps/StytchDemo/ContentView.swift#L26)    

* **StytchUIDemo**  
Bundle ID: `com.stytch.StytchUIDemo`  
[Configure the public token](../Stytch/DemoApps/StytchUIDemo/ContentView.swift#L112)  
[Configure the URL Scheme](../Stytch/DemoApps/StytchUIDemo/Info.plist#L14)  

* **StytchB2BUIDemo**  
Bundle ID: `com.stytch.StytchB2BUIDemo`  
[Configure the public token](../Stytch/DemoApps/StytchB2BUIDemo/ContentView.swift#L51)  
[Configure the URL Scheme](../Stytch/DemoApps/StytchB2BUIDemo/Info.plist#L12)  

* **B2BWorkbench**  
Bundle ID: `com.stytch.B2BWorkbench`  
[Configure the public token](../Stytch/DemoApps/B2BWorkbench/ViewControllers/B2BWorkbenchViewController.swift#L5)  
URL Scheme to add to your [dashboard](https://stytch.com/dashboard/redirect-urls): b2bworkbench://auth

* **ConsumerWorkbench**  
Bundle ID: `com.stytch.ConsumerWorkbench`  
[Configure the public token](../Stytch/DemoApps/ConsumerWorkbench/ViewControllers/ConsumerWorkbenchViewController.swift#L5)  
URL Scheme to add to your [dashboard](https://stytch.com/dashboard/redirect-urls): consumerworkbench://auth

* **StytchBiometrics**  
Bundle ID: `com.stytch.StytchBiometrics`  
[Configure the public token](../Stytch/DemoApps/StytchBiometrics/ViewController.swift#L19)  

* **StytchSessions**  
Bundle ID: `com.stytch.StytchSessions`  
[Configure the public token for consumer sessions](../Stytch/DemoApps/StytchSessions/StytchConsumerSessionsViewController.swift#L33)  
[Configure the public token for B2B sessions](../Stytch/DemoApps/StytchSessions/StytchB2BSessionsViewController.swift#L35)    

## 5. Running the Sample Apps

You can select which target/app and which simulator you would like to run from the following menu. Then to run the target/app you chose you can press `⌘R`.

![Stytch Targets](assets/target_options.png)

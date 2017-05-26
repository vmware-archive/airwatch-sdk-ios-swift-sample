//
//  AppDelegate.swift
//  AirWatch-SDK-iOS-Swift
//
//  Copyright © 2017 VMware, Inc.  All rights reserved
//
//  The BSD-2 license (the ìLicenseî) set forth below applies to all parts of the AirWatch-SDK-iOS-Swift
//  project.  You may not use this file except in compliance with the License.
//
//  BSD-2 License
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//	  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit
import AWSDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,AWSDKDelegate {
    
    
    var window: UIWindow?
    var sdkUseCase = SDKUseCasesTableViewController()
    var awSDKInit: Bool? = false

    // MARK:- UI Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Configure the controller.
        let controller = AWController.clientInstance()
        
        //Define the callback. This should match with the entry in the info.plist
        controller?.callbackScheme = "iosswiftsample"
        
        //Set the delegate.
        controller?.delegate = self
    
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Calling the SDK's start function when application becomes active
        AWController.clientInstance().start()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Defaulting to use SDK for openURL
        return AWController.clientInstance().handleOpen(url, fromApplication: sourceApplication)
    }
    
    // MARK: - AWSDKDelegate
    
    func initialCheckDoneWithError(_ error: Error!) {
        NSLog("initialCheckDoneWithError called")
        
        if error != nil {
 
            sdkUseCase.hideBlocker()
            NSLog("initialCheckDone With  Error")
            awSDKInit=true
            let alertController = UIAlertController(title: "AWInit  Reporter", message:
                "An error occured while initializing AW SDK", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))

        } else {
            sdkUseCase.hideBlocker()
            NSLog("initialCheckDone NO Error")
            awSDKInit=true
        }
    }
       
    func receivedProfiles(_ profiles: [Any]!) {
        
        NSLog("received profiles called")
        
        // Profiles
        if profiles != nil {
            
            if let awProfiles = profiles as? [AWProfile] {
                NSLog ("Now printing the profiles")
                for profile in awProfiles {
                    NSLog (profile.displayName);
                 
                    print("full profile \(profile.toDictionary())")
                    }
            }
            
            if let awPayload = profiles as? [AWProfilePayload] {
                NSLog("Now printing the payloads")
                for payload in awPayload {
                    print(payload)
                }
            }
        } else {
            NSLog("receivedProfiles is nil")
        }
        
    }
    
    func wipe() {
        NSLog("wipe")
    }
    
    func lock() {
        NSLog("lock")
    }
    
    func unlock() {        
        NSLog("unlock")
    }
    
    func resumeNetworkActivity() {
        NSLog("resumeNetworkActivity")
    }
    
    func stopNetworkActivity(_ networkActivityStatus: AWNetworkActivityStatus) {
    }
    
}


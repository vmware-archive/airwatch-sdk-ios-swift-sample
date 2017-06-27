//
//  AppDelegate.swift
//  AirWatch-SDK-iOS-Swift-Sample
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
class AppDelegate: UIResponder, UIApplicationDelegate, AWControllerDelegate {
    
    
    var window: UIWindow?

    // MARK:- UI Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Configure the controller.
        let controller = AWController.clientInstance()
        
        //Define the callback. This should match with the entry in the info.plist
        controller.callbackScheme = "iosswiftsample"
        
        //Set the delegate.
        controller.delegate = self
        
        // Start the SDK
        controller.start()
    
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Defaulting to use SDK for openURL
        return AWController.clientInstance().handleOpenURL(url, fromApplication: sourceApplication)
    }
    
    // MARK: - AWSDKDelegate
    
    func controllerDidFinishInitialCheck(error: NSError?) {
        NSLog("initialCheckDoneWithError called")
        
        /*
         * There is not a guarantee that the AWController Delegates will be called on the main thread.
         * Since this sample is removing a UI Blocker once InitialCheck is called, we are updating that on
         * the main thread.
         */
        if error != nil {
            OperationQueue.main.addOperation {
                NSLog("initialCheckDone With Error")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AW SDK INIT"), object: error)
            }
        } else {
            OperationQueue.main.addOperation {
                NSLog("initialCheckDone With NO Error")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AW SDK INIT"), object: nil)
            }
        }
    }
    
    func controllerDidReceive(profiles: [Profile]) {
        
        NSLog("received profiles called")
        
        for profile in profiles {
            NSLog("Profile: %@" , profile.displayName ?? "No display name")
            
            // The content of the payload is sent as a dictionary
            let payload = profile.toDictionary()
            
            // Unwrapping the array of the Profile payload content
            if let content = payload["PayloadContent"] {
                print("SDK Profile Content \(content)")
            }
        }
    }
    
    func controllerDidWipeCurrentUserData() {
        NSLog("wipe")
    }
    
    func controllerDidLockDataAccess() {
        NSLog("lock")
    }
    
    func controllerDidUnlockDataAccess() {
        NSLog("unlock")
    }
    
    func applicationCanResumeNetworkActivity() {
        NSLog("resumeNetworkActivity")
    }
    
    func applicationShouldStopNetworkActivity(reason: AWSDK.NetworkActivityStatus) {
        NSLog("stopnetworkActivity")
    }
    
}


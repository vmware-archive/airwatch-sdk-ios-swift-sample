//
//  Utils.swift
//  AirWatch-SDK-iOS-Swift-Sample
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

import Foundation
import AWSDK
import UIKit

public class GeneralUtils {

    public typealias validationCompletionHandler = ((String) ->(Swift.Void))?
    public typealias updateUserCompletionHandler = (() ->(Swift.Void))?

    
    //MARK:- Helper methods
    public static func stripDomain(fromUsername username: String) -> String {
        let usernameParts = username.components(separatedBy: "\\")
        
        if usernameParts.count > 1 {
            return usernameParts[1]
        }
        
        return usernameParts[0]
    }
    
    
    // Check for the formatting of the entered URL
    public static func getURLStringFromTextField(urlText : String?) -> String {
        guard var urlString = urlText else {
            return ""
        }
        
        if(urlString.isEmpty){
            urlString = "https://www.vmware.com"
            
        } else if (!(urlString.hasPrefix("http://")) && !(urlString.hasPrefix("https://"))){
            urlString = "https://" + urlString
        }
        
        urlString = urlString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        print("Final URL is \(urlString)")
        
        return urlString
    }

    
    
    /*
     * Different websites return different kind of encoding
     * getting the correct encoding from the response which we used later
     * to populate and render the data returned by website inside the webivew.
     */
    public static func getCorrectEncoding(_ response : URLResponse) -> UInt{
        var usedEncoding = String.Encoding.utf8
        if let encodingName = response.textEncodingName {
            let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString!))
            if encoding != UInt(kCFStringEncodingInvalidId) {
                usedEncoding = String.Encoding(rawValue: encoding)
            }
            return usedEncoding.rawValue
        }
        else{
            return usedEncoding.rawValue
        }
    }
    
    public static func showLoadingIndicator(){
        OperationQueue.main.addOperation({
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
    }
    
    
    public static func hideLoadingIndicator(){
        OperationQueue.main.addOperation({
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
    
    
    
    //MARK:- Local credential Validation
    
    /*
     On some rare events AWEnrollmentAccount class shared Instance might become nil. This obect is used by the
     SDK challenge handler classes to seamlesasly pass the credentials in response to the basic and NTLM type
     authentication challenge. We check if the shared instance is nil or corrupted below
     */
    public static func accountObjectCheck(requestingViewController : UIViewController, completionHandler : validationCompletionHandler){
        /*
         If the account object is nil we are calling updateUserCredentialsWithCompletion block
         that shoudl repopulate the credentils in the instance
         */
        let username = AWController.clientInstance().account.username
        
        if(username == "") {
            print("account username is empty")
            if let currentCompletionHandler = completionHandler{
                currentCompletionHandler("SDK Account object is nil")
            }
            
        } else {
            /*
             Sometimes when a device is re-enrolled with a different user or is checked out in the staging
             user flow, Account object might fail to update it's data accordingly. We use AWMDMInformationController to
             get the username and compare it with the username retured by Account object
             */
            UserInformationController.sharedInstance.retrieveUserInfo(completionHandler: {
                userInformation, error in
                
                if error != nil {
                    print("Error retrieving device information from AirWatch with: \(error.debugDescription)")
                    
                    // Show a dialog indicating FetchInfo Failure
                    OperationQueue.main.addOperation {
                        AlertHandler.displayFetchUserInfoError(requestingViewController: requestingViewController)
                    }
                }
                
                /*
                 * In the event that the account object is not nil but fails to update the username correctly, e.g.
                 * after a Check In / Check Out we call updateUserCredentialsWithCompletion that should correctly
                 * populate the data inside account object which is used by SDK challenge handler classes.
                 */
                
                // Fetch Server user
                let serverUser = GeneralUtils.stripDomain(fromUsername: (userInformation?.userName)!)
                
                // Fetch local user
                let sdkUser = GeneralUtils.stripDomain(fromUsername: AWController.clientInstance().account.username)
                
                // Compare both users
                if(sdkUser.lowercased() != serverUser.lowercased()) {
                    if let currentCompletionHandler = completionHandler{
                        currentCompletionHandler("Current SDK User does not match Server User")
                    }
                }
            })
        }
    }
    
    
    //This SDK API will prompt user to authenticate and if the authentication is successufull with backend, local credentials will be updated.
    public static func updateUserCreds(requestingViewController : UIViewController,completionHandler : updateUserCompletionHandler) -> Void {
        AWController.clientInstance().updateUserCredentials(with: { (success, error) in
            if(success){
                print("updated credentials and trying to log in with updated credentials")
                OperationQueue.main.addOperation({
                    AlertHandler.tryAgain(requestingViewController: requestingViewController)
                    if let currentCompletionHandler = completionHandler{
                        currentCompletionHandler()
                    }
                })
            } else{
                print("error occured \(error ?? "error" as! Error)")
            }
        })
    }
    

    

}



    

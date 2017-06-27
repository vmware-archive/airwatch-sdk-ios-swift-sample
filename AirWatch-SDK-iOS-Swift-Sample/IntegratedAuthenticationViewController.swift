//
//  IntegratedAuthenticationViewController.swift
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

class IntegratedAuthenticationViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, NSURLConnectionDelegate {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var httpStatusLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateCredentialsButton: UIBarButtonItem?
    
    
    override func viewDidLoad() {
        
        /*
         * Checking the SDK Account object
         */
        accountObjectCheck()
        loadingIndicator.hidesWhenStopped = true
        
        let borderColor = UIColor.black.cgColor
        webView.layer.borderColor = borderColor
        webView.layer.borderWidth = 2.0
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IntegratedAuthenticationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        hideUpdateButton()
    }
    
    //MARK:- UI Actions
    @IBAction func didTapGoButton(_ sender: AnyObject) {
        // Reset status label
        httpStatusLabel.text = ""
        
        // Grab URL and make request
        let urlString = getURLStringFromTextField()
        if let url = URL(string: urlString){
            sessionGetRequest(url)
        } else {
            displayInvalidURL()
        }
    }
    
    @IBAction func didTapUpdateCredentials(_ sender: Any) {
        updateUserCreds()
    }
    
    func setHTTPStatusLabel(_ status: String) {
        httpStatusLabel.text = status
    }
    
    func updateLabel(_ withString : String){
        OperationQueue.main.addOperation({
            // Set the labels based on the data/response values
            self.httpStatusLabel.text?.append("-> \(withString)")
        })
    }
    
    //MARK:- URLSession
    func sessionGetRequest(_ url: URL) {
        
        //Creating request and starting the session
        let request = URLRequest(url: url)
        print(request.url!)
        let configuration = Foundation.URLSession.shared.configuration
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        
        //Handling the data and response returned by session task
        let task = session.dataTask(with: request, completionHandler: {
            taskData, taskResponse, error in
            if let data = taskData, let response: HTTPURLResponse = taskResponse! as? HTTPURLResponse{
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.httpStatusLabel.text = "HTTP Code: \(response.statusCode)"

                if(response.mimeType != nil && response.textEncodingName != nil && response.url != nil){
                    
                    // Updating the UI on the Main thread.
                    OperationQueue.main.addOperation({
                        
                        self.webView.load(data, mimeType: response.mimeType!, textEncodingName: response.textEncodingName!, baseURL: response.url!)
                    })
                } else {
                    let dataString = String(data: data, encoding:String.Encoding(rawValue: self.getCorrectEncoding(response)) )
                    // Updating the UI on the Main thread.
                    OperationQueue.main.addOperation({
                        
                        self.webView.loadHTMLString(dataString!, baseURL:response.url!)
                    })
                }
                
                print("Clearing out the session for security purposes")
                session.invalidateAndCancel()
                session.finishTasksAndInvalidate()
            }
        })
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        task.resume()
    }
    
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
      
        
        if challenge.previousFailureCount == 2 {
            /* Handling the case where password might have changed in the AD.
             Updating the credentials in the SDK keychain an promting user to try again.
             */
            self.updateUserCreds()
        } else if challenge.previousFailureCount > 2 {
            // Display an alert to the user indicating the failure
            displayLoginError()
            // Cancel the request/challenge if more than 1 attempt has failed.
            completionHandler(.cancelAuthenticationChallenge, nil)
            
        } else {
            /*
             * For debugging purposes, we're printing the Authentication Method of the endpoint.
             * This was helpful in determining if the endpoint the api was hitting, was actually able
             * to use Integrated Authentication.
             */
            print(challenge.protectionSpace.authenticationMethod)
            
            switch challenge.protectionSpace.authenticationMethod {
                /*
                 * Integrated Authentication does not handle Server Trust, if an endpoint is presenting this
                 * as the authentication method, then the developer needs to handle that prior to Integrated
                 * Authentication handling authentication. Below we're checking to see if the method is explicitly
                 * server trust. We're using an if/else statement to handle server trust if need and perform integrated
                 * authentication otherwise.
                 */
            case NSURLAuthenticationMethodServerTrust:
                /*
                 * The completion handler is handling server trust below. We're telling it to handle it and not
                 * passing it any credentials
                 */
                updateLabel("challenge type is ServerTrust")
                completionHandler(.performDefaultHandling,nil)
                break
                /*
                 * Below are the three types of authentication type that is supporedted by SDK.
                 * Checking if one of the suppored authentication is received and
                 * calling SDK's handle challenge method to handle the corresponding challenge
                 */
            case NSURLAuthenticationMethodHTTPBasic:
                updateLabel("challenge type is Basic")
                handleAirWatchIntegratedAuthenticationforSession(challenge,completionHandler: completionHandler)
                break
            case NSURLAuthenticationMethodNTLM:
                updateLabel("challenge type is NTLM")
                handleAirWatchIntegratedAuthenticationforSession(challenge,completionHandler: completionHandler)
                break
            case NSURLAuthenticationMethodClientCertificate:
                updateLabel("challenge type is Cert Based")
                handleAirWatchIntegratedAuthenticationforSession(challenge,completionHandler: completionHandler)
                break
                /*
                 * If the auth challenge type is any other then basic, NTLM or cert auth
                 * then it's not supported by SDK and developer has to handle it manually
                 */
            default:
                print("Authentication challenge is not one supported by the SDK...cancelling challenge")
                completionHandler(.cancelAuthenticationChallenge, nil)
                displayNotSupportedAlert()
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(error != nil){
            print("Error occured during session \(error!)")
        }
    }
    
    /*
     * This delegate method is called when response data is recieved in chunks or
     * in one shot.
     */
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask,
                    didReceiveData data: Data) {
        
        print("Data received: \(data)")
    }
    
    // MARK:- AirWatch SDK
    
    /*
     * In order to leverage Integrated Authentication two steps need to be performed.
     * First a check that the protection space is one that the SDK can handle and second,
     * that it has the credentials needed in order to move forward. If both of these checks
     * are ok then call "handleChallenge" in order for the SDK to take care of the challenge.
     */
    func handleAirWatchIntegratedAuthenticationforSession(_ challenge: URLAuthenticationChallenge,completionHandler: @escaping (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        do {
            try AWController.clientInstance().canHandle(protectionSpace: challenge.protectionSpace)
            _ = AWController.clientInstance().handleChallengeForURLSession(challenge: challenge, completionHandler: { (disposition, credential) in
                completionHandler(disposition, credential)
            })
        } catch {
            print(error)
        }
    }
    
    func updateUserCreds() -> Void {
        AWController.clientInstance().updateUserCredentials(with: { (success, error) in
            if(success){
                print("updated credentials and trying to log in with updated credentials")
                OperationQueue.main.addOperation({
                    self.tryAgain()
                    self.hideUpdateButton()
                })
            } else{
                print("error occured \(error ?? "error" as! Error)")
            }
        })
    }
    
    /*
     On some rare events AWEnrollmentAccount class shared Instance might become nil. This obect is used by the
     SDK challenge handler classes to seamlesasly pass the credentials in response to the basic and NTLM type
     authentication challenge. We check if the shared instance is nil or corrupted below
     */
    func accountObjectCheck(){
        
        /*
         If the account object is nil we are calling updateUserCredentialsWithCompletion block
         that shoudl repopulate the credentils in the instance
         */
        let username = AWController.clientInstance().account.username
        
        if(username == "") {
            print("account username is empty")
            
            displayAWAccountError(withMessage: "SDK Account object is nil")
            
        } else {
            /*
             Sometimes when a device is device is re-enrolled with a different user or is checked out in the staging
             user flow, Account object might fail to update it's data accordingly. We use AWMDMInformationController to
             get the username and compare it with the username retured by Account object
             */
            UserInformationController.sharedInstance.retrieveUserInfo(completionHandler: {
                userInformation, error in
                
                if error != nil {
                    print("Error retrieving device information from AirWatch with: \(error.debugDescription)")
                    
                    // Show a dialog indicating FetchInfo Failure
                    OperationQueue.main.addOperation {
                        self.displayFetchUserInfoError()
                    }
                }
                
                /*
                 * In the event that the account object is not nil but fails to update the username correctly, e.g.
                 * after a Check In / Check Out we call updateUserCredentialsWithCompletion that should correctly
                 * populate the data inside account object which is used by SDK challenge handler classes.
                 */
                
                // Fetch Server user
                let serverUser = self.stripDomain(fromUsername: (userInformation?.userName)!)
                
                // Fetch local user
                let sdkUser = self.stripDomain(fromUsername: AWController.clientInstance().account.username)
                
                // Compare both users
                if(sdkUser.lowercased() != serverUser.lowercased()) {
                    self.displayAWAccountError(withMessage: "Current SDK User does not match Server User")
                }
            })
        }
    }
    
    //MARK:- Helper methods
    
    /*
     * Different websites return different kind of encoding
     * getting the correct encoding from the response which we used later
     * to populated and render the data returned by webiste inside the webivew.
     */
    func getCorrectEncoding(_ response : URLResponse) -> UInt{
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
    
    // Check for the formatting of the entered URL
    func getURLStringFromTextField() -> String {
        guard var urlString = urlTextField.text else {
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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func stripDomain(fromUsername username: String) -> String {
        let usernameParts = username.components(separatedBy: "\\")
        
        if usernameParts.count > 1 {
            return usernameParts[1]
        }
        
        return usernameParts[0]
    }
    
    func showUpdateButton() {
        self.httpStatusLabel.text = "Account Object needs to be updated. Please click update"
        self.updateCredentialsButton?.isEnabled = true
        self.updateCredentialsButton?.tintColor = UIColor.init(colorLiteralRed: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    }
    
    func hideUpdateButton() {
        httpStatusLabel.text = ""
        updateCredentialsButton?.isEnabled = false
        updateCredentialsButton?.tintColor = UIColor.clear
    }
    
    // MARK:- Messages / Dialogs
    
    func displayAWAccountError(withMessage message: String) -> Void {
        print("AW SDK Account Issue")
        
        let alert = UIAlertController(title: "AirWatch SDK Account", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Update", style: .default, handler: {
            _ in
            print("Ok clicked")
            self.updateUserCreds()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            _ in
            self.showUpdateButton()
        })
        
        alert.addAction(okAction)
        alert.addAction(cancel)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }

    }
    
    func displayLoginError() -> Void {
        print("Log In error with Int Auth")
        
        displayAlert(withTitle: "SDK Error", withMessage: "An Error Occured while SDK was trying to perform Integrated Auth. Please make sure your enrollment credentials have access to this endpoint")
    }
    
    func tryAgain() -> Void {
        print("Credentials Updated...try again")
        
        displayAlert(withTitle: "Credentials Updated", withMessage: "Credentials Updated successfully, Please try again!")
    }
    
    func displayFetchUserInfoError() -> Void {
        print("Log In error :: unable to fetch server information")
        
        displayAlert(withTitle: "SDK Error", withMessage: "An Error Occured while SDK was trying to fetch user infor from AW backed. Please make sure your device is enrolled")
    }
    
    func displayInvalidURL() -> Void{
        print("Log in Error :: invalid URL")
        
        displayAlert(withTitle: "Invalid URL", withMessage: "Please confirm the formatting of the URL")
    }
    
    func displayNotSupportedAlert() -> Void{
        print("Log In error :: Not supported")
        
        displayAlert(withTitle: "Authentication Required", withMessage: "This type of Authentication challenge is not supported by the SDK")
    }
    
    func displayAlert(withTitle title: String, withMessage message: String) {
        print("Log In error")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            _ in
            print("Dismiss")
        })
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }

    }

}

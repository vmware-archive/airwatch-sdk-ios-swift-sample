//
//  IntegratedAuthenticationViewController.swift
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

class IntegratedAuthenticationViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, NSURLConnectionDelegate {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var httpStatusLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var credentials: URLCredential?
    var connectionResponse : URLResponse?
    var connectionData : NSMutableData?
    
    // Set this value to false if Integrated Auth will not be leveraged by the app
    var integratedAuthEnabled = true
    
    
    @IBAction func doIntegratedAuth(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("NSRURLConnection")
            webView.loadRequest(URLRequest.init(url:URL.init(string: "about:blank")! ))
            httpStatusLabel.text=""
            break
        case 1:
            print("NSURLSession")
            webView.loadRequest(URLRequest.init(url:URL.init(string: "about:blank")! ))
            httpStatusLabel.text=""
            
            
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        
        /*
         * Calling a fallback method to update account object in case it's nil or corrupted
         * Manually feteching the user's credentials and adding them to an NSURLCredential Object
         */
        print("view loaded again")
        accountObjectCheck()
        loadingIndicator.hidesWhenStopped = true
        
        let borderColor = UIColor.black.cgColor
        webView.layer.borderColor = borderColor
        webView.layer.borderWidth = 2.0
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IntegratedAuthenticationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func didTapGoButton(_ sender: AnyObject) {
        
        let urlString = getURLStringFromTextField()
        if let url = URL(string: urlString){
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                print("NSRURLConnection")
//                connectGetRequest(url)
                
                break
            case 1:
                print("NSURLSession")
                sessionGetRequest(url)
                
                break
            default:
                break
            }
        }
        else{
            displayInvalidURL()
        }
        
    }
    
    
    func loadWebViewWithString(_ stringData: String) {
        webView.loadHTMLString(stringData, baseURL: URL(string: "https://www.vmware.com"))
        
    }
    
    func setHTTPStatusLabel(_ status: String) {
        httpStatusLabel.text = status
    }
    
    //MARK: NSURLSession
    
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

                if(response.mimeType != nil && response.textEncodingName != nil && response.url != nil){
                    
                    // Updating the UI on the Main thread.
                    OperationQueue.main.addOperation({
                        
                        self.webView.load(data, mimeType: response.mimeType!, textEncodingName: response.textEncodingName!, baseURL: response.url!)
                    })
                }
                    
                else{
                    
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
        }
        else if challenge.previousFailureCount > 2 {
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
                 Below are the three types of authentication type that is supporedted by SDK.
                 Checking if one of the suppored authentication is received and
                 calling SDK's handle challenge method to handle the corresponding challenge
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
                 If the auth challenge type is any other then basic, NTLM or cert auth
                 then it's not supported by SDK and developer has to handle it manually
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
    
    
    //MARK : Helper methods
    
    func updateLabel(_ withString : String){
        OperationQueue.main.addOperation({
            // Set the labels based on the data/response values
            self.httpStatusLabel.text?.append("-> \(withString)")
            
            
        })
        
    }
    
    func displayLoginError() -> Void {
        print("Log In error")
        
        let alert = UIAlertController(title: "SDKError", message: "An Error Occured while SDK was trying to perform Integrated Auth. Please make sure your enrollment credentials have access to this endpoint", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
        })
        
        
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation({
            // Set the labels based on the data/response values
            self.present(alert, animated: true, completion: nil)
            
            
        })
        
    }
    
    
    
    func tryAgain() -> Void {
        print("Log In error")
        
        
        
        let alert = UIAlertController(title: "Credentials Updated", message: "Credentials Updated successfully, Please try again!", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
        })
        
        
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation({
            // Set the labels based on the data/response values
            self.present(alert, animated: true, completion: nil)
            
            
        })
        
    }
    
    func displayFetchUserInfoError() -> Void {
        print("Log In error")
        
        let alert = UIAlertController(title: "SDKError", message: "An Error Occured while SDK was trying to fetch user infor from AW backed. Please make sure your device is enrolled", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
        })
        
        
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation({
            // Set the labels based on the data/response values
            self.present(alert, animated: true, completion: nil)
            
            
        })
        
    }
    
    func displayInvalidURL() -> Void{
        print("Log In error")
        
        let alert = UIAlertController(title: "Invalid URL", message: "Please confrim the formatting of the URL", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
        })
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func displayNotSupportedAlert() -> Void{
        print("Log In error")
        
        let alert = UIAlertController(title: "Authentication Required", message: "This type of Authentication challenge is not supported by the SDK", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismis", style: .default, handler: {
            action in
            print("Dismiss")
        })
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    /*:
     This delegate method is called when response data is recieved in chunks or
     in one shot.
     */
    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask,
                    didReceiveData data: Data) {
        
        print("data came \(data)")
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
        if(AWController.clientInstance().account == nil) {
            print("account obj nil")
            
            AWController.clientInstance().updateUserCredentials(with: { (success, error) in
                if(success)
                {
                    print("successfully populated account object")
                }
                else
                {
                    print("Error has occured :\(String(describing: error))")
                }
            })
        } else {
             /*
             Sometimes when a device is device is re-enrolled with a different user or is checked out in the staging
             user flow, Account object might fail to update it's data accordingly. We use AWMDMInformationController to
             get the username and compare it with the username retured by Account object
             */
//            AWMDMInformationController.init().fetchUserInfo(completionBlock: { (success, userinfo, error) in
//                
//                if(error == nil && success){
//                    let mdmInfo = userinfo! as NSDictionary
//                    let mdmUserName = mdmInfo.value(forKey: "UserName")! as! String
//                    let accountUserName = AWController.clientInstance().account().username
//                    if(mdmUserName.lowercased() == accountUserName?.lowercased()){
//                        print("mdmusername and account username matches, returning")
//                        return
//                    }
//                    let parts = mdmUserName.components(separatedBy: "\\")
//                    let mdmUser : String
//                    //Handling the case where mdmuesrname is of format adname\username
//                    let lastElement  = parts[parts.count-1]
//                    
//                    if(!(lastElement.isEmpty)){
//                        mdmUser = lastElement
//                        
//                    }
//                    else{
//                        mdmUser = mdmUserName
//                    }
//                    print("mdm username is \(mdmUser)")
//                    print("account username is \(accountUserName)")
//                    
//                    
//                    /*
//                     In the event if the account object is not nil but fails to update the username correctly we call
//                     updateUserCredentialsWithCompletion that should correctly populate the data inside account object
//                     which is used by SDK challenge handler classes
//                     */
//                    if(mdmUser.lowercased() != accountUserName?.lowercased()){
//                        print("account object incorrect")
//                        
//                        AWController.clientInstance().updateUserCredentials(completion: { (success, error) in
//                            if(success){
//                                print("successfully populated account object")
//                                let user = AWController.clientInstance().account().username
//                                print("current username is \(user)" )
//                            }
//                            else{
//                                print("error occured \(error)")
//                            }
//                        })
//                    }
//                }
//                else{
//                    OperationQueue.main.addOperation {
//                        self.displayFetchUserInfoError()
//                        
//                    }
//                }
//            })
        }
    }
    
    
    /*
     Different websites return different kind of encoding
     getting the correct encoding from the response which we used later
     to populated and render the data returned by webiste inside the webivew.
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
    
    //Check for the formatting of the entered URL
    
    func getURLStringFromTextField() -> String {
        var urlString = urlTextField.text
        
        
        if(urlString!.isEmpty){
            urlString = "https://www.vmware.com"
            
        }
        else if (!(urlString!.hasPrefix("http://")) && !(urlString!.hasPrefix("https://"))){
            urlString! = "https://" + urlString!
        }
        
        urlString! = urlString!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("Final URL is \(urlString!)")
        return urlString!
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func updateUserCreds() -> Void {
        AWController.clientInstance().updateUserCredentials(with: { (success, error) in
            if(success){
                print("updated credentials and trying to log in with updated credentials")
                OperationQueue.main.addOperation({
                    self.tryAgain()
                })
                
            }
            else{
                print("error occured \(error ?? "error" as! Error)")
            }
        })
    }
    
    
    
}

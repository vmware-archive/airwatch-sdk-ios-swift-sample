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
import Alamofire

class IntegratedAuthenticationViewController: UIViewController, AlamofireHandlerDelegate, URLSessionHandlerDelegate {
  
 
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var httpStatusLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateCredentialsButton: UIBarButtonItem?
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    var updateUserCredsStatus : Bool = false
    
    
    override func viewDidLoad() {
        
        /** 
         Checking the SDK Account object. This is done to ensure SDK's integrated auth logic
         doesn't use stale credentials to handle network challenge. It is optional but a recommended check 
         before using SDK's integrated auth APIs.
         */
        GeneralUtils.accountObjectCheck(requestingViewController: self, completionHandler: { errorMessage in
            self.displayAWAccountError(message: errorMessage)
        })
        
        /**
         Setting UI component on this View.
         */
        loadingIndicator.hidesWhenStopped = true
        
        let borderColor = UIColor.black.cgColor
        webView.layer.borderColor = borderColor
        webView.layer.borderWidth = 2.0
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IntegratedAuthenticationViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        hideUpdateButton()
        
    }
    
    
    
    
    @IBAction func segmentControlDidChange(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("URLSession tab selected")
            webView.loadRequest(URLRequest.init(url:URL.init(string: "about:blank")! ))
            break
        case 1:
            print("Alamofire tab selected")
            webView.loadRequest(URLRequest.init(url:URL.init(string: "about:blank")! ))
            break
        default:
            break
        }
    }
    
    
    @IBAction func didTapGoButton(_ sender: AnyObject) {
        // Reset status label
        httpStatusLabel.text = ""
        
        // Grab URL and make request
        let urlString = GeneralUtils.getURLStringFromTextField(urlText: self.urlTextField.text)
        
        switch segmentedControl.selectedSegmentIndex {
            
        // Performing URLSession based Networking
        case 0:
            if let url = URL(string: urlString){
               GeneralUtils.showLoadingIndicator()
               let sessionHandler = URLSessionHandler(requestURL: url)
               sessionHandler.delegate = self
               sessionHandler.initiateRequest()
            } else {
                AlertHandler.displayInvalidURL(requestingViewController: self)
            }
            break
        
        // Performing Alamofire based Networking
        case 1:
            if let url = URL(string: urlString){
                GeneralUtils.showLoadingIndicator()
                let alamoHandler = AlamofireHandler(requestURL : url)
                alamoHandler.delegate = self
                alamoHandler.initiateRequest()
            } else {
                AlertHandler.displayInvalidURL(requestingViewController: self)
            }
            break
        default:
            break
        }
    }
    
    
    @IBAction func didTapUpdateCredentials(_ sender: Any) {
        self.updateUserCreds()
    }
    
    
    
    //MARK:- URLSession delegate callbacks implementation to update UI
    
    func urlSessionDidRecieveChallenge(challenge: URLAuthenticationChallenge?,sdkSupported : Bool) {
        self.updateViewWithChallengeResult(challenge: challenge, sdkSupported: sdkSupported)
        
    }
    
    func urlSessionRequestDidComplete(response: HTTPURLResponse?, data: Data?, error : Error?) {
        
        if let currentError = error{
            print("Error occured during URLSession \(currentError)")
            GeneralUtils.hideLoadingIndicator()
        }else{
            if let currentResponse = response, let currentData = data{
                OperationQueue.main.addOperation({
                    self.httpStatusLabel.text = "HTTP Code: \(currentResponse.statusCode)"
                })
                GeneralUtils.hideLoadingIndicator()
                self.updateWebViewWithData(response: currentResponse, withData: currentData)
            }
        }
        
    }
    
    func awSDKDidCompleteSessionChallenge(result: Bool?) {
        if let currentResult = result{
            if(!currentResult && self.updateUserCredsStatus){
                AlertHandler.displayLoginError(requestingViewController: self)
            }
        }
    }
    
    
    
    
    //MARK:- Alamofire delegate callbacks implementation to update UI
    
    func alamofireDidRecieveChallenge(challenge: URLAuthenticationChallenge?,sdkSupported : Bool) {
        self.updateViewWithChallengeResult(challenge: challenge, sdkSupported: sdkSupported)
    }
    
    
    func alamofireRequestDidReceiveData(response: HTTPURLResponse, data: Data) {
        OperationQueue.main.addOperation({
            self.httpStatusLabel.text = "HTTP Code: \(response.statusCode)"
        })
        GeneralUtils.hideLoadingIndicator()
        self.updateWebViewWithData(response: response, withData: data)
    }
    
    
    func alamofireRequestDidComplete(task: URLSessionTask?, error: Error?) {
        if let currentError = error{
            print("Error occured during Alamofire session \(currentError)")
            GeneralUtils.hideLoadingIndicator()
        }
    }
    
    
    func awSDKDidCompleteAlamoChallenge(result: Bool?) {
        if let currentResult = result{
            if(!currentResult && self.updateUserCredsStatus){
                AlertHandler.displayLoginError(requestingViewController: self)
            }
        }
    }
    
    
    
 

    //MARK:- UI Actions
    
    func setHTTPStatusLabel(_ status: String) {
        httpStatusLabel.text = status
    }
    
    func updateLabel(_ withString : String){
        OperationQueue.main.addOperation({
            // Set the labels based on the data/response values
            self.httpStatusLabel.text?.append("-> \(withString)")
        })
    }
    
    func updateViewWithChallengeResult(challenge: URLAuthenticationChallenge?,sdkSupported : Bool){
        if let currentChallenge = challenge{
            if(sdkSupported){
                updateLabel("challenge type is : \(currentChallenge.protectionSpace.authenticationMethod)")
                
                /**
                 Checking updateUserCredsStatus to see if the local credentials have been already updated by
                 calling updateUserCreds method. If yes, then enrolled active user doesn't seem to have access
                 to web service endpoint.
                 */
                if(currentChallenge.previousFailureCount == 1 && self.updateUserCredsStatus){
                    AlertHandler.displayLoginError(requestingViewController: self)
                }
                
                /**
                 Handling the case where password might have changed in the AD.
                 Updating the credentials in the SDK keychain once and promting user to try again.
                 */
                if(currentChallenge.previousFailureCount == 1 && !self.updateUserCredsStatus){
                    self.updateUserCreds()
                }
                
            }else{
                GeneralUtils.hideLoadingIndicator()
                AlertHandler.displayNotSupportedAlert(requestingViewController: self)
            }
        }
    }
    
    func updateWebViewWithData(response: HTTPURLResponse,withData data: Data){
        if(response.mimeType != nil && response.textEncodingName != nil && response.url != nil){
            // Updating the UI on the Main thread.
            OperationQueue.main.addOperation({
                self.webView.load(data, mimeType: response.mimeType!, textEncodingName: response.textEncodingName!, baseURL: response.url!)
            })
        } else {
            let dataString = String(data: data, encoding:String.Encoding(rawValue: GeneralUtils.getCorrectEncoding(response)) )
            // Updating the UI on the Main thread.
            OperationQueue.main.addOperation({
                self.webView.loadHTMLString(dataString!, baseURL:response.url!)
            })
        }
    }
    
    
    
    func dismissKeyboard() {
        view.endEditing(true)
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
    

    
    
   
    /**
     Displaying the prompt to request user for updating the account object.
     If user clicks "Ok", this will show an authentication screen.
     */
    
    func displayAWAccountError(message: String)  {
        
        AlertHandler.displayAlertWithCompletionHandler(
            requestingViewController: self,
            withTitle: "AirWatch SDK Account",
            withMessage: message,
            
            okHandler: {
                _ in
                self.updateUserCreds()
               },
            
            cancelHandler: {
                _ in
                self.showUpdateButton()
        })
    }
    
    
    /**
     Redirecting to the updateUserCreds implementation present in GeneralUtil class.
     */
    func updateUserCreds()  {
        GeneralUtils.updateUserCreds(requestingViewController: self, completionHandler: { success in
            
            //Credentials were updated successfully. Requsting User to try again.
            if(success){
                AlertHandler.tryAgain(requestingViewController: self)
                self.hideUpdateButton()
                self.updateUserCredsStatus = true
            }
           
        })
    }

    
  

}

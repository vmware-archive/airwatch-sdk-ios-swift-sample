//
//  TunnelingViewController.swift
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

class TunnelingViewController: UIViewController, UIWebViewDelegate,URLSessionDelegate {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseLabel.text = ""
        loadingIndicator.hidesWhenStopped = true
        let borderColor = UIColor.black.cgColor
        webView.layer.borderColor = borderColor
        webView.layer.borderWidth = 2.0
        webView.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TunnelingViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - UISegmentedControl
    
    @IBAction func segmentedControlChanged(_ sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            print("WebView")
            webView.loadRequest(URLRequest.init(url:URL.init(string: "about:blank")! ))
            responseLabel.text = ""
            break
        case 1:
            print("NSURLSession")
            webView.loadRequest(URLRequest.init(url:URL.init(string: "about:blank")! ))
            responseLabel.text = "HTTP Status"
            break
        default:
            break
        }
    }
    
    
    // MARK - Networking
    // There is no additional SDK calls required to proxy the traffic form iOS Networking claases via AirWatch Tunnel
    // However there are some limitations to this. Please refer SDK guide to read more about these limitations
    
    @IBAction func handleRequest(_ sender: AnyObject) {
        let urlString = getURLStringFromTextField()
        if let url = URL(string: urlString){
            let request: URLRequest = URLRequest(url: url)
            
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                makeSessionRequest(request,networkType: 0)
                break
            case 1:
                makeSessionRequest(request,networkType: 1)
                break
            default:
                break
            }
        }
        else{
            displayInvalidURL()
        }
    }
    
    
    //Making the session request and using session task to do the networking.
    func makeSessionRequest(_ request: URLRequest,networkType: Int) {
        let request = URLRequest(url: request.url!)
        let configuration = Foundation.URLSession.shared.configuration
        let session: URLSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request, completionHandler: {
            taskData, taskResponse, error in
            if let data = taskData, let response: HTTPURLResponse = taskResponse! as? HTTPURLResponse {
                
                
                //Laoding the task data into the webview if webview (0) is selected
                if(networkType==0){
                    
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
                    
                }
                    //Setting the response label on the UI if the NSURLSession is selected
                else{
                    // Set the labels based on the data/response values
                    
                    OperationQueue.main.addOperation({
                        self.responseLabel.text = "HTTP: \(response.statusCode)"
                    })
                }
                
                //Invalidating the session once UI has been updated with the task data and response
                session.invalidateAndCancel()
                session.finishTasksAndInvalidate()
            }
        }) 
        task.resume()
    }
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didReceiveChallenge challenge: URLAuthenticationChallenge, completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Printing a message here to demonstrate the callback being called.
        print("didReceiveTaskChallenge")
        
        if challenge.previousFailureCount > 1 {
            // Display an alert to the user indicating the failure
            displayAlert()
            // Cancel the request/challenge if more than 1 attempt has failed, will display a message to the user
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
                completionHandler(.performDefaultHandling,nil)
                break
                
                /*
                 Below are the three types of authentication type that is supporedted by SDK.
                 Checking if one of the suppored authentication is received and alerting user
                 to make this call from the Integrated Authentication ViewController
                 */
            case NSURLAuthenticationMethodHTTPBasic:
                displayAlert()
                
                break
            case NSURLAuthenticationMethodNTLM:
                displayAlert()
                
                break
            case NSURLAuthenticationMethodClientCertificate:
                displayAlert()
                
                break
                /*
                 If the auth challenge type is any other then basic, NTLM or cert auth
                 then it's not supported by SDK and developer has to handle it manually
                 */
            default:
                print("Authentication challenge is not one supported by the SDK...cancelling challenge")
                displayNotSupportedAlert()
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            
        }
        
    }
    
    
    // MARK: - WebView Delegates
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //self.loadingIndicator.hidden = false
        //self.loadingIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.segmentedControl.isHidden=true
        
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if(webView.isLoading){
            return
        }

        //Hide networking indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        segmentedControl.isHidden=false        
        
    }
    
    // MARK: - Utilities
    
    //Check for the formatting of the entered URL
    func getURLStringFromTextField() -> String {
        var urlString = urlTextField.text
        
        
        if(urlString!.isEmpty)
        {
            urlString = "https://www.vmware.com"
            
        }
        else if (!(urlString!.hasPrefix("http://")) && !(urlString!.hasPrefix("https://")))
        {
            urlString! = "https://" + urlString!
        }
        
        urlString! = urlString!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("Final URL is \(urlString!)")
        return urlString!
    }
    
    
    //Mark : Helper Alert methods
    //Displaying error alert if Endpoint require any kind of authentication
    func displayAlert() -> Void {
        print("Log In error")
        
        let alert = UIAlertController(title: "Authentication Required", message: "Tunneling was successfull and we were able to hit the endpoint but this URL requires authentication. Please refer the Integrated Authentication ViewController OR access a URL that does not need authentication", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
            self.responseLabel.text = "Authentication Required"
        })
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func displayNotSupportedAlert() -> Void{
        print("Log In error")
        
        let alert = UIAlertController(title: "Authentication Required", message: "Tunneling was successfull and we were able to hit the endpoint but this type of Authentication challenge is not supported by the SDK", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
            self.responseLabel.text = "Authentication Required"
        })
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func displayInvalidURL() -> Void{
        print("Log In error")
        
        let alert = UIAlertController(title: "Invalid URL", message: "Please confrim the formatting of the URL", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
            action in
            print("Dismiss")
            self.responseLabel.text = "Invalid URL"
        })
        alert.addAction(okAction)
        
        OperationQueue.main.addOperation {
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //Mark : Helper webiew methods
    
    //Getting the correct encoding from the response to populate the webview
    func getCorrectEncoding(_ response : HTTPURLResponse) -> UInt{
        var usedEncoding = String.Encoding.utf8
        if let encodingName = response.textEncodingName {
            let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString!))
            if encoding != UInt(kCFStringEncodingInvalidId) {
                usedEncoding = String.Encoding(rawValue: encoding)
            }
            return usedEncoding.rawValue
        }
        else
        {
            return usedEncoding.rawValue
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    
}

//
//  URLSessionNetworkingHandler.swift
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

import Foundation
import AWSDK
import UIKit

/**
 IntegratedAuthenticationViewController will  delegate the networking logic to URLSessionNetworkingHandler
 and will get notififed of networking activity by confirming to URLSessionHandlerDelegate protocol
 */
public protocol URLSessionHandlerDelegate{
    func urlSessionDidRecieveChallenge(challenge : URLAuthenticationChallenge?, sdkSupported : Bool)
    func urlSessionRequestDidComplete(response : HTTPURLResponse?,data : Data?, error : Error?)
    func awSDKDidCompleteSessionChallenge(result : Bool?)

}



public class URLSessionHandler : NSObject, URLSessionTaskDelegate, URLSessionDelegate {
  
    /**
     delegate : variable holding the instance of the class confirming to AlamofireHandlerDelegate protocol.
     url : URL passed by the caller class to initiate Alamofire request.
     sessionManager : Global varialbe to hold Alamofire session manager instance.
     */
    var delegate : URLSessionHandlerDelegate?
    var url : URL?
    var session : URLSession?
    
    init(requestURL : URL) {
        self.url = requestURL
    }
    
    
    func initiateRequest(){
    
    if let requestURL = self.url{
        //Creating request and starting the session
        let request = URLRequest(url: requestURL)
        let configuration = Foundation.URLSession.shared.configuration
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        print(request.url!)
        self.sessionGetRequest(request: request)
        }
    }
    
    
    
    //MARK:- URLSession
    func sessionGetRequest(request : URLRequest) {
        let task = self.session!.dataTask(with: request, completionHandler: {
            taskData, taskResponse, error in

            if let data = taskData, let response: HTTPURLResponse = taskResponse! as? HTTPURLResponse{
                
                if let sessionDelegate = self.delegate{
                    sessionDelegate.urlSessionRequestDidComplete(response: response, data: data, error: error)
                    print("Clearing out the session for security purposes")
                    self.session!.invalidateAndCancel()
                    self.session!.finishTasksAndInvalidate()
                }
                
            }
        })
        
        print("Starting session")
        task.resume()
    }
    
    
    //Delegate callbacks implementation to handle the authentication challenge returned by the server
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
        if let sessionDelegate = self.delegate{
            print("URLSession Challenge type : \(challenge.protectionSpace.authenticationMethod)")
            switch challenge.protectionSpace.authenticationMethod {
            case NSURLAuthenticationMethodServerTrust:
                completionHandler(.performDefaultHandling,nil)
                sessionDelegate.urlSessionDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                break
                
            case NSURLAuthenticationMethodHTTPBasic :
                self.offloadAuthenticationToAWSDK(challenge : challenge, completionHandler: completionHandler)
                sessionDelegate.urlSessionDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                break
                
            case NSURLAuthenticationMethodNTLM:
                self.offloadAuthenticationToAWSDK(challenge : challenge, completionHandler: completionHandler)
                sessionDelegate.urlSessionDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                break
                
            case NSURLAuthenticationMethodClientCertificate:
                self.offloadAuthenticationToAWSDK(challenge : challenge, completionHandler: completionHandler)
                sessionDelegate.urlSessionDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                break
                
            default:
                print("AW SDK can't handle this type of authentication challenge")
                completionHandler(.cancelAuthenticationChallenge, nil)
                sessionDelegate.urlSessionDidRecieveChallenge(challenge: challenge, sdkSupported: false)
                break
            }
        }
    }
    
    
    
    //Using AW SDK's API to handle the supported auth challenge
    func offloadAuthenticationToAWSDK(challenge : URLAuthenticationChallenge,completionHandler: @escaping ((URLSession.AuthChallengeDisposition,URLCredential?) -> Swift.Void))  {
        let awAuthHandleStatus  = AWController.clientInstance().handleChallengeForURLSession(challenge: challenge, completionHandler: completionHandler)
        print("Did SDK attempt to handle this challenge : \(awAuthHandleStatus)")
        
        //Notifying the ViewController that SDK had to canel the authentication challenge
        if let sessionDelegate = self.delegate, !awAuthHandleStatus{
            sessionDelegate.awSDKDidCompleteSessionChallenge(result: false)
        }
    }
    
    
    
   

}

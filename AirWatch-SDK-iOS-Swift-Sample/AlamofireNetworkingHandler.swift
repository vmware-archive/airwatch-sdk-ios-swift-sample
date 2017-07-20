//
//  AlamofireNetworkingHandler.swift
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
import Alamofire
import AWSDK


/**
 IntegratedAuthenticationViewController will  delegate the networking logic to AlamforeNetworkingHandler
 and will get notififed of networking activity by confirming to AlamofireHandlerDelegate protocol
 */

public protocol AlamofireHandlerDelegate {
    func alamofireDidRecieveChallenge(challenge : URLAuthenticationChallenge?, sdkSupported : Bool)
    func alamofireRequestDidReceiveData(response : HTTPURLResponse, data : Data )
    func alamofireRequestDidComplete(task : URLSessionTask?,error : Error?)
    func awSDKDidCompleteAlamoChallenge(result : Bool?)

}


public class AlamofireHandler {
    
    /**
    delegate : variable holding the instance of the class confirming to AlamofireHandlerDelegate protocol.
    url : URL passed by the caller class to initiate Alamofire request.
    sessionManager : Global varialbe to hold Alamofire session manager instance.
    */
    var delegate : AlamofireHandlerDelegate?
    var url : URL?
    let sessionManager : Alamofire.SessionManager?
    
    
    
    init(requestURL : URL) {
        self.url = requestURL
        self.sessionManager = Alamofire.SessionManager.default
        
        if let manager = self.sessionManager{
            let delegate : Alamofire.SessionDelegate = manager.delegate
            
            setChallengeDelegate(delegate: delegate)
            setDataDelegate(delegate: delegate)
            setCompletionDelegate(delegate: delegate)
        }
      
    }
    
    
    /**
     Entry function to initiate a network request
     */
    func initiateRequest(){
        if let manager = self.sessionManager{
            if let requestURL = self.url{
                manager.request(requestURL)
            }
        }
    }
    
    
    //Delegate callbacks implementation to handle the authentication challenge returned by the server
    func setChallengeDelegate(delegate : Alamofire.SessionDelegate )  {
        
        delegate.taskDidReceiveChallengeWithCompletion = { session, task, challenge,  completionHandler in
            if let alemoDelegate = self.delegate{
                print("Alamofire Challenge type : \(challenge.protectionSpace.authenticationMethod)")
                switch challenge.protectionSpace.authenticationMethod {
                case NSURLAuthenticationMethodServerTrust:
                    completionHandler(.performDefaultHandling,nil)
                    alemoDelegate.alamofireDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                    break
                    
                case NSURLAuthenticationMethodHTTPBasic :
                    self.offloadAuthenticationToAWSDK(challenge : challenge, completionHandler: completionHandler)
                    alemoDelegate.alamofireDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                    break
                    
                case NSURLAuthenticationMethodNTLM:
                    self.offloadAuthenticationToAWSDK(challenge : challenge, completionHandler: completionHandler)
                    alemoDelegate.alamofireDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                    break
                    
                case NSURLAuthenticationMethodClientCertificate:
                    self.offloadAuthenticationToAWSDK(challenge : challenge, completionHandler: completionHandler)
                    alemoDelegate.alamofireDidRecieveChallenge(challenge: challenge, sdkSupported: true)
                    break
                    
                default:
                    print("AW SDK can't handle this type of authentication challenge")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    alemoDelegate.alamofireDidRecieveChallenge(challenge: challenge, sdkSupported: false)
                    break
                }
            }

            
        }
    }
    
    //Delegate callback implementation to recieve the response and the data.
    func setDataDelegate(delegate : Alamofire.SessionDelegate)  {
        
        delegate.dataTaskDidReceiveData = {session , task, data in
            
            if let response: HTTPURLResponse = task.response as? HTTPURLResponse{
                if let alamoDelegate = self.delegate{
                    alamoDelegate.alamofireRequestDidReceiveData(response: response,data: data)
                }
            }
            
        }
        
    }
    
    //Delegate callback implementation to catch any error after the task is finished
    func setCompletionDelegate(delegate : Alamofire.SessionDelegate)  {
        
        delegate.taskDidComplete = { session, task , error in
            
            print()
            if let alamoDelegate = self.delegate{
                alamoDelegate.alamofireRequestDidComplete(task : task,error: error)
            }
        }
        
    }
    

    
    //Using AW SDK's API to handle the supported auth challenge
    func offloadAuthenticationToAWSDK(challenge : URLAuthenticationChallenge,completionHandler: @escaping ((URLSession.AuthChallengeDisposition,URLCredential?) -> Swift.Void))  {
        let awAuthHandleStatus  = AWController.clientInstance().handleChallengeForURLSession(challenge: challenge, completionHandler: completionHandler)
        print("Did SDK attempt to handle this challenge : \(awAuthHandleStatus)")
        
        
        //Notifying the ViewController that SDK had to canel the authentication challenge
        if let alamoDelegate = self.delegate, !awAuthHandleStatus{
            alamoDelegate.awSDKDidCompleteAlamoChallenge(result: false)
        }
    }
    
    
    
    
    
    
}




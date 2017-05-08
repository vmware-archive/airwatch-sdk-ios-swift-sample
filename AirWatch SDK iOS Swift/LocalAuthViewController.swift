//
//  LocalAuthViewController.swift
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

class LocalAuthViewController: UIViewController {

    var pageTitles:NSArray!
    var pageImages:NSArray!
    var detail1:NSString!
    var detail2:NSString!
    var detail3:NSString!


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Populating the Data to be loading in the WalkThthrough
        // for local authentication
        detail1 = "An app passcode can ensure the app is only accessible to the entitled user and that the user identity is maintained over time. A biometric, such as TouchID, can typically be implemented as a layer above the PIN code to optimize the user experience."
        
        
        
        detail2 = "Organisation can opt to choose Username and Password instead of a PIN to allow secure access to the AW SDK application. These credentials are the same as the enrollment credentials"
        
        
        detail3 = "SSO stands for single sign on.It basically allows a user to access multiple SDK applications by only entering a single password/passcode once as opposed to multiple times for each application that the user needs.Please make sure to align the SSO settings under custom SDK profile and Default SDK profile as shown in the screenshot"
        
        
        // Disposing of any resources that can be recreated.
        self.pageTitles = NSArray(objects: detail1, detail2,detail3)
        self.pageImages = NSArray(objects: "Passcode", "UsernamePassword","SSO")
    }
    
    

    @IBAction func loadWalkThrough(_ sender: UIButton) {
        self.performSegue(withIdentifier: "authToWT", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
   
    }
    


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        // Create a new variable to store the instance of WalkThthrough View Controller
        let destinationVC = segue.destination as! WalkThroughViewController
        destinationVC.pageDescription = self.pageTitles
        destinationVC.pageMedia = self.pageImages
        
        
    }

}

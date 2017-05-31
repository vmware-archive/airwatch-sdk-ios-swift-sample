//
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

class CustomSettingsViewController: UIViewController {
    
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    @IBOutlet weak var customSettingsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageTitles = NSArray(objects: "Step-1", "Step-2","Step-3")
        self.pageImages = NSArray(objects: "EditSDKProfile", "EditCustomSettings","AssignSDKProfile")
        
        let borderColor = UIColor.black.cgColor
        customSettingsTextView.layer.borderColor = borderColor
        customSettingsTextView.layer.borderWidth = 2.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func printSettings(_ sender: AnyObject) {

        let customPayload: CustomPayload = (AWController.clientInstance().sdkProfile()?.customPayload)!
        
        //Checking if the Custom Settings Payload is nil or not set
        guard let customSettings: String = customPayload.settings else { return }
        
        if(customSettings == ""){
            alertUser(withMessage: "Custom settings payload is either blank or not configured in SDK Profile")
        } else{
            updateTextView(withString: customSettings)
        }
        
    }

    // MARK: - Alert/UI
    func alertUser(withMessage customMessage:NSString){
        
        let alertController = UIAlertController(title: "Custom Settings",
                                                message: customMessage as String,
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss",
                                                style: UIAlertActionStyle.default,
                                                handler: nil))
        
        
        alertController.addAction(UIAlertAction(title: "Learn More",
                                                style: UIAlertActionStyle.default,
                                                handler: { (alertAction) -> Void in
                                                    
            self.performSegue(withIdentifier: "segueSWT", sender: self)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateTextView(withString customSettings: String){
        customSettingsTextView.text = customSettings as String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        // Create a new variable to store the instance of WalkThthrough View Controller
        let destinationVC = segue.destination as! WalkThroughViewController
        destinationVC.pageDescription = self.pageTitles
        destinationVC.pageMedia = self.pageImages
        
    }
}
 



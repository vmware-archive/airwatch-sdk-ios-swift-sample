//
//  GeneralInformationViewController.swift
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

class GeneralInformationViewController: UITableViewController {

    let data = SDKData()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        /*
         fetchUserInfoWithCompletionBlock is an asyncronous call that returns the below mentioned 
         NSDIctionary which we later parsed to get the user and device related information
        */
//        AWMDMInformationController.init().fetchUserInfo(completionBlock: { (success, userinfo, error) in
//            
//            //This API will throw an error if the device is not enrolled.
//            if(error == nil && success)
//            {
//                let mdmInfo = userinfo as AnyObject
//                
//                let awUserName = SDKData.EnrollmentInformation(key: "Username:",value: (mdmInfo.value(forKey: "UserName")!) as! String)
//                let awlocationGroup = SDKData.EnrollmentInformation(key: "Location Group:",value: (mdmInfo.value(forKey: "LocationGroup")!) as! String)
//                let awAccountType = SDKData.EnrollmentInformation(key: "Account Type:",value: (mdmInfo.value(forKey: "AccountType")!) as! String)
//                let awIsActive = SDKData.EnrollmentInformation(key: "Is Active:",value: (mdmInfo.value(forKey: "IsActive")!) as! String)
//                let awUserCategory = SDKData.EnrollmentInformation(key: "User Category:",value: (mdmInfo.value(forKey: "UserCategory")!) as! String)
//                let awUserID = SDKData.EnrollmentInformation(key: "User ID:",value: (mdmInfo.value(forKey: "UserId")!) as! String)
//                
//                
//                self.data.mdmInformationArray[0] = awUserName
//                self.data.mdmInformationArray[1] = awlocationGroup
//                self.data.mdmInformationArray[2] = awAccountType
//                self.data.mdmInformationArray[3] = awIsActive
//                self.data.mdmInformationArray[4] = awUserCategory
//                self.data.mdmInformationArray[5] = awUserID
//                
//                
//                self.tableView.reloadData()
//            }
//            else
//            {
//                print("Error occured while contacing AW Rest API to get the user info : \(error?.localizedDescription ?? "No error")")
//                
//                    OperationQueue.main.addOperation {
//                        self.displayFetchUserInfoError()
//                        
//                    }
//                
//            }
//         
//
//        })
        // Do any additional setup after loading the view.
    }
    
    func displayFetchUserInfoError() -> Void {
//        print("Log In error")
//        
//        let alert = UIAlertController(title: "SDKError", message: "An Error Occured while SDK was trying to fetch user infor from AW backed. Please make sure your device is enrolled", preferredStyle: .alert)
//        
//        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
//            action in
//            print("Dismiss")
//        })
//        alert.addAction(okAction)
//        OperationQueue.main.addOperation({
//            // Set the labels based on the data/response values
//            self.present(alert, animated: true, completion: nil)
//            
//            
//        })
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



//MARK : SDK SDKData


class SDKData {
    class EnrollmentInformation {
        let key : String
        let value: String
        init(key : String,value: String) {
            self.key = key
            self.value = value
        }
    }
    
    /*
     Creating place holder array for the data which will be returned by fetchUserInfoWithCompletionBlock
    */
    var mdmInformationArray = [
        EnrollmentInformation(key: "Username: ",value: "Loading..."),
        EnrollmentInformation(key: "Location Group: ",value: "Loading..."),
        EnrollmentInformation(key: "Account Type: ",value: "Loading..."),
        EnrollmentInformation(key: "Is Active: ",value: "Loading..."),
        EnrollmentInformation(key: "User Category: ",value: "Loading..."),
        EnrollmentInformation(key: "User ID: ",value: "Loading..."),
//        EnrollmentInformation(key: "Server Name:",value: (AWServer.sharedInstance().deviceServicesURL.deletingLastPathComponent().absoluteString)),
    ]
    
    
 
}
    
    //Mark : TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int{
        return data.mdmInformationArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SDKInfoTableViewCell
        cell.separatorInset = UIEdgeInsets.zero;
        
        let entry = data.mdmInformationArray[indexPath.row]
        cell.keyLabel.text = entry.key
        cell.valueLabel.text = entry.value
        return cell
    }
    
    
}



class SDKInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

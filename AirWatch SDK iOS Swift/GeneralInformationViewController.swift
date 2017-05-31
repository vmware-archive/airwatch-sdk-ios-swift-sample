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
        
        // SDK API calls separated for readability
        fetchUserInfo()
        fetchDeviceInfo()
    }
    
    /*
     * fetchDeviceInformation is an asyncronous call that returns the below
     * DeviceInformation object which we later parsed to get the device related information
     */
    func fetchDeviceInfo() -> Void {
        DeviceInformationController.sharedController.fetchDeviceInformation(completion: {
            (deviceInformation, error) in
            
            if (error != nil) {
                print("Error fetching information: \(error.debugDescription)")
                OperationQueue.main.addOperation {
                    self.displayFetchUserInfoError()
                }
                return
            }
            
            /*
             * Fetching properties from DeviceInformation instance
             */
            
            // Enrollment Status - See below extension for possible values / enums
            let enrolled = AWSDK.EnrollmentStatus(rawValue: (deviceInformation?.enrollmentStatus.rawValue)!)?.stringTitle()
            self.data.deviceInformationArray[0].value = enrolled!
            
            // Current compliance status - See below extension for possible values / enums
            let complaint = AWSDK.ComplianceStatus(rawValue: (deviceInformation?.complianceStatus.rawValue)!)?.stringTitle()
            self.data.deviceInformationArray[1].value = complaint!
            
            // Organization group info
            self.data.deviceInformationArray[2].value = (deviceInformation?.groupName)!
            self.data.deviceInformationArray[3].value = (deviceInformation?.groupID)!
            
            // Displays Management Status - See below extension for possible values / enums
            let mgmtType = AWSDK.DeviceManagmentType(rawValue: (deviceInformation?.managementType.rawValue)!)?.stringTitle()
            self.data.deviceInformationArray[4].value = mgmtType!
            
            // Bool check for Management
            self.data.deviceInformationArray[5].value = deviceInformation?.isManaged.description ?? "N/A"

            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        })

    }
    
    /*
     * retrieveUserInfo is an asyncronous call that returns the below
     * UserInformation object which we later parsed to get the user related information
     */
    func fetchUserInfo() {
        UserInformationController.sharedInstance.retrieveUserInfo { (userInformation, error) in
            if (error != nil) {
                print("Error fetching information: \(error.debugDescription)")
                OperationQueue.main.addOperation {
                    self.displayFetchUserInfoError()
                }
                return
            }
            
            // Username
            self.data.userInformationArray[0].value = (userInformation?.userName)!
            
            // Group ID
            self.data.userInformationArray[1].value = (userInformation?.groupID)!
            
            // Email Address
            self.data.userInformationArray[2].value = (userInformation?.email)!
            
            // Full Name
            let firstName: String = (userInformation?.firstName)!
            let lastName: String = (userInformation?.lastName)!
            self.data.userInformationArray[3].value = firstName.appending(lastName)
            
            // Domain
            self.data.userInformationArray[4].value = (userInformation?.domain)!
            
            // User ID
            self.data.userInformationArray[5].value = (userInformation?.userIdentifier)!
            
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    func displayFetchUserInfoError() -> Void {
        print("Log In error")
        
        let alert = UIAlertController(title: "SDKError", message: "An Error Occured while SDK was trying to fetch user info from AW backed. Please make sure your device is enrolled", preferredStyle: .alert)
        
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark : TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int{
        var count = -1
        
        switch section {
        case 0:
            return data.userInformationArray.count
        case 1:
            return data.deviceInformationArray.count
        default:
            count = 0
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SDKInfoTableViewCell
        cell.separatorInset = UIEdgeInsets.zero;
        
        var entry: SDKData.EnrollmentInformation?
        
        if indexPath.section == 0 {
            entry = data.userInformationArray[indexPath.row]
        } else if indexPath.section == 1 {
            entry = data.deviceInformationArray[indexPath.row]
        }
        
        cell.keyLabel.text = entry?.key
        cell.valueLabel.text = entry?.value
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "User Information"
        } else if section == 1 {
            return "Device Information"
        }
        
        return ""
    }
    
}

//MARK : SDK SDKData

class SDKData {
    // Constants
    static let LOADING = "Loading..."
    static let ENROLLED = "Enrolled: "
    static let COMPLIANT = "Compliant: "
    static let ORG_GROUP = "Org Group: "
    static let ORG_GROUP_ID = "Org Group ID: "
    static let MGMT_TYPE = "MGMT Type: "
    static let IS_MANAGED = "Is Managed: "
    static let USERNAME = "Username: "
    static let USER_OG = "User Org Group: "
    static let EMAIL = "Email Address: "
    static let FULL_NAME = "Full Name: "
    static let DOMAIN = "Domain: "
    static let USER_ID = "User ID: "
    
    
    class EnrollmentInformation {
        let key : String
        var value: String
        init(key : String,value: String) {
            self.key = key
            self.value = value
        }
    }
    
    /*
     Creating place holder array for the data which will be returned by fetchUserInfoWithCompletionBlock
    */
    var userInformationArray = [
        EnrollmentInformation(key: SDKData.USERNAME,value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.USER_OG,value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.USERNAME,value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.FULL_NAME,value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.DOMAIN,value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.USER_ID,value: SDKData.LOADING),
    ]
    
    var deviceInformationArray = [
        EnrollmentInformation(key: SDKData.ENROLLED, value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.COMPLIANT, value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.ORG_GROUP, value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.ORG_GROUP_ID, value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.MGMT_TYPE, value: SDKData.LOADING),
        EnrollmentInformation(key: SDKData.IS_MANAGED, value: SDKData.LOADING)
    ]

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

// MARK:- AWSDK Extensions
/*
 * Below are a few extensions to return a String from some
 * AWSDK enums
 */

extension AWSDK.DeviceManagmentType {
    func stringTitle() -> String {
        
        switch self {
            
        case .notManaged:
            return "Not Managed"
        case .managedByMDM:
            return "Managed by MDM"
        case .managedByMAM:
            return "Managed by MAM"
        case .quarantine:
            return "Quarantine"
        case .unknown:
            return "Unknown"
        }
    }
}

extension AWSDK.ComplianceStatus {
    func stringTitle() -> String {
        switch self {
        case .allowed:
            return "Allowed"
        case .blocked:
            return "Blocked"
        case .compliant:
            return "Compliant"
        case .nonCompliant:
            return "Non Compliant"
        case .notApplicable:
            return "Not Applicable"
        case .notAvailable:
            return "Not Available"
        case .pendingComplianceCheck:
            return "Pending Compliance Check"
        case .pendingComplianceCheckForAPolicy:
            return "Pending Compliance Check for a policy"
        case .quarantined:
            return "Quarantined"
        case .registrationActive:
            return "Registration Active"
        case .registrationExpired:
            return "Registration Expired"
        case .unknown:
            return "Unknown"
        }
    }
}

extension AWSDK.EnrollmentStatus {
    func stringTitle() -> String {
        switch self {
        case .enrolled:
            return "Enrolled"
        case .unenrolled:
            return "Unerolled"
        case .enrollmentInProgress:
            return "Enrollment in Progress"
        case .enterpriseWipePending:
            return "Enterprise Wipe Pending"
        case .deviceNotFound:
            return "Device not Found"
        case .deviceWipePending:
            return "Device Wipe Pending"
        case .discovered:
            return "Discovered"
        case .registered:
            return "Registered"
        case .retired:
            return "Retired"
        case .unknown:
            return "Unknown"
        }
    }
}

//
//  SDKUseCasesTableViewController.swift
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

class SDKUseCasesTableViewController: UITableViewController {

    var loadingView  = LoadingIndicatorView();

    /*
     A static class which act as a gateway to different AW SDK Use cases
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        /*
        ** THIS IS WHERE WE ARE SHOWING THE BLOCKER SCREEN**
         We should wait for SDK to initialize completely before attempting to utilize any SDK resource for example trying to
         attemp tunneling. This blocker screens is completely optional but is shown to demonstrate good practise.
        */
        let sdkStatus = appDelegate?.awSDKInit
                if  (sdkStatus == false){
                    print("inside sdk usecases")
                    LoadingIndicatorView.show(self.parent!.view, loadingText: "Initializing SDK...")
                }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Blocker Screen
    
    func showBocker(){
        print("Showing Blocker")
    }
    
    func hideBlocker() {
        print("hiding Blocker")
        LoadingIndicatorView.hide()
    }

    // MARK: - Table view data source
    // Currently empty since static table cell sources are being used
}

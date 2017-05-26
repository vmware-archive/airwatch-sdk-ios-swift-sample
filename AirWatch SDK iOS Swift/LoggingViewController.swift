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

class LoggingViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var AppendToLog: UIButton!
    
    @IBOutlet weak var crashApp: UIButton!
    
    @IBOutlet weak var sendAppLog: UIButton!
    
    @IBOutlet weak var logLevelPicker: UIPickerView!
    
    @IBOutlet weak var logInputField: UITextField!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var hasPreviousCrashText: UILabel!
    
    let pickerData = ["Verbose", "Info", "Warning", "Error"]
    var logLevelChoice = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logLevelPicker.isHidden = false;
        self.sendAppLog.isHidden = false;
        self.AppendToLog.isHidden = false;
        self.logInputField.isHidden = false;
        self.hasPreviousCrashText.isHidden = true;
        self.crashApp.isHidden = true;
        
        logInputField.delegate = self
        logLevelPicker.delegate = self
        logLevelPicker.dataSource = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoggingViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK - UISegmentedControl
    
    
    @IBAction func segmentedControlChagned(_ sender: AnyObject) {
//        AWLog.sharedInstance().log(withLogLevel: AWLogLevelVerbose, file: "LoggingViewController", methodName: "sendAppLog", line: 1234, message: "AirWatch Sample App Logging Test...")
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            
            print("App Log")
            
            self.logLevelPicker.isHidden = false;
            self.sendAppLog.isHidden = false;
            self.AppendToLog.isHidden = false;
            self.logInputField.isHidden = false;
            self.hasPreviousCrashText.isHidden = true;
            self.crashApp.isHidden = true;
            
            break
        case 1:
            //Send crash log if previous crash is logged. Then initialize a crash log session
            print("Crash Log")
            
            self.logLevelPicker.isHidden = true;
            self.sendAppLog.isHidden = true;
            self.AppendToLog.isHidden = true;
            self.logInputField.isHidden = true;
            self.hasPreviousCrashText.isHidden = false;
            self.crashApp.isHidden = false;


            
            break
        default:
            break
        }
    }

    
    
    // MARK - picker delegate - The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK - picker delegate -The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // MARK - picker delegate - The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    // MARK - picker delegate - Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        logLevelChoice = row
    }
    
    
    
    // MARK: -crash the app
    @IBAction func crashTheApp(_ sender: UIButton) {
        let myCrashArray = [1, 2];
        _ = myCrashArray[2];
    }
    
    
    // MARK: -select all when edit text is selected
    func textFieldDidBeginEditing(_ textField: UITextField) {
        logInputField.becomeFirstResponder()
        logInputField.selectAll(nil)
    }
    
    // MARK: Append user input to current application log.
    //This is to showcase the ability to customize applicationg logging and provide developers to log content as they desire
    
    
    @IBAction func appendToLog(_ sender: AnyObject) {
        guard let text = logInputField.text else {
            return
        }
        //var logLevel = pickerData[logLevelChoice]
        //var awLogLevel = AWLogLevelVerbose
        
        switch logLevelChoice {
        case 0:
            AWLogVerbose(text)
            print("capturing verbose logs")
            break;
        case 1:
            AWLogInfo(text)
            print("capturing infomation logs")
            break;
        case 2:
            AWLogWarning(text)
            print("capturing warning logs")
            break;
        case 3:
            AWLogError(text)
            print("capturing error logs")

            break;
        default:
            break;
        }
    }
    
    

    
    // MARK: Send application log up till this point to AW console
    
    @IBAction func sendAppLog(_ sender: AnyObject) {
        AWController().sendLogDataWithCompletion({
            (success, errorName) in
            
            if(false == success){
                NSLog("Error is : \(errorName?.localizedDescription ?? "No error")");
            } else {
                NSLog("Sucess");
            }
        })
        
        let alertController = UIAlertController(title: "AW Log Reporter", message:
            "Sent Log to AirWatch Console..", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}







//
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

class LoggingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var AppendToLog: UIButton!
    @IBOutlet weak var sendAppLog: UIButton!
    @IBOutlet weak var logLevelPicker: UIPickerView!
    @IBOutlet weak var logInputField: UITextField!
    
    let pickerData = ["Verbose", "Info", "Warning", "Error"]
    var logLevelChoice = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // MARK: Append user input to current application log.
    @IBAction func appendToLog(_ sender: AnyObject) {
        guard let text = logInputField.text else {
            return
        }
        
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
            
            if(!success){
                NSLog("Error is : \(errorName?.localizedDescription ?? "No error")");
                OperationQueue.main.addOperation {
                    self.showAlert(withMessage: "Error sending logs")
                }
            } else {
                NSLog("Sucess");
                OperationQueue.main.addOperation {
                    self.showAlert(withMessage: "Logs sent to AW")
                }
            }
        })
    }
    
    // MARK:- select all when edit text is selected
    func textFieldDidBeginEditing(_ textField: UITextField) {
        logInputField.becomeFirstResponder()
        logInputField.selectAll(nil)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "AWSDK Log Reporter",
                                                message: message,
                                                preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK:- UIPicker Delegate and Datasource

extension LoggingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        logLevelChoice = row
    }
}

extension LoggingViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

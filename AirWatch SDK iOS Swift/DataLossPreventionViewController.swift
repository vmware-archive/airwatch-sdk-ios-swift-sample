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


import UIKit
import AWSDK

class DataLossPreventionViewController: UIViewController,UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var headingTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var learnMoreButton: UIButton!
  
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    

    
    var alertMessageDLP: NSString = ""
    var currentSelection:Int = 0
    var pageAppDLPTitles,pageOverlayDLPTitles, pageEditingDLPTitles, pageMoreDLPTitles: NSArray!
    var pageAppDLPImages,pageOverlayDLPImages, pageEditingDLPImages, pageMoreDLPImages: NSArray!

    
 
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addSwipeRecognizer()
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]
        startRestrictionService()
        setupWalkThroughMaterial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(currentSelection == 3){
        setAppDLPViews()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    
    //Starting the restriction service so it can fetch all the DLP flags from AW backend.
    func startRestrictionService()  {
        do{
         try   AWRestrictions.startService()
        }
        catch{
            print("Error occured while starting restriction service \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func didTapLearnMore(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueDLP", sender: self)
    }
    
  
    
    //MARK : Methods to control the Application DLP Settings

    @IBAction func didTapButton1(_ sender: AnyObject) {
        
        if let restrictionPayload = AWCommandManager().sdkProfile().restrictionsPayload{
        
            let dlpSettings = restrictionPayload.enableDataLossPrevention
            if(dlpSettings == false){
            alertUser(withMessage: alertMessageDLP)
            }
            else{
                let url = URL(string: "mailto:exampleuser@example.com")
                UIApplication.shared.openURL(url!)
            }
        }
        
        else{
         alertUser(withMessage:alertMessageDLP)
        }
    }
    
    
    @IBAction func didTapButton2(_ sender: AnyObject) {
        
        
        if let restrictionPayload = AWCommandManager().sdkProfile().restrictionsPayload{
            
            let dlpSettings = restrictionPayload.enableDataLossPrevention
            if(dlpSettings == false){
                alertUser(withMessage: alertMessageDLP)
            }
            else{
                let url = URL(string: "https://www.vmware.com")
                UIApplication.shared.openURL(url!)
            }
        }
            
        else{
            alertUser(withMessage: alertMessageDLP)
        }
        
    }

    
    //MARK : Tab Bar Switching Contoller

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        switch item.tag {
        case 0:
            setAppDLPViews()
            break
        case 1:
            setBlockerDLPViews()
            break
        case 2:
            setEditingDLPViews()
            break
        case 3:
            setMoreDLPViews()
            break
        default:
            break
        }
    }

    
    func addSwipeRecognizer()  {
        
        let directions : [UISwipeGestureRecognizerDirection] = [.right,.left]
        
        for direction in directions{
            let gesture = UISwipeGestureRecognizer(target:self,action: #selector(self.handleSwipe(sender:)))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
        
    }
    
    func handleSwipe(sender : UISwipeGestureRecognizer)  {
        
        if(currentSelection == 0 && sender.direction.rawValue==1){
            setEditingDLPViews()
        }
        else if(currentSelection == 0 && sender.direction.rawValue==2){
            setBlockerDLPViews()
        }
        else if(currentSelection == 1 && sender.direction.rawValue==1){
            setAppDLPViews()
        }
            
        else if(currentSelection == 1 && sender.direction.rawValue==2){
            setEditingDLPViews()
            
        }
        else if(currentSelection == 2 && sender.direction.rawValue==1){
            setBlockerDLPViews()
        }
        else if(currentSelection == 2 && sender.direction.rawValue==2){
            setAppDLPViews()
            
        }
        else{
            //Do nothing
        }
        
        
    }

    
    
    
    
    //MARK: NON SDK Util Methods
    
    func setAppDLPViews()  {
        currentSelection = 0
        tabBar.selectedItem = tabBar.items![0]
        firstButton.isHidden = false
        secondButton.isHidden = false
        headingTextView.text = "Restrict data to be opened in AirWatch applications"
         descriptionTextView.text = "SDK Applications can be configured so that HTTP/HTTPS and MAILTO links can be automatically sent to VMware productivity apps.Click Learn more to explore!"
        
    }
    
    func setBlockerDLPViews()  {
        currentSelection = 1
        tabBar.selectedItem = tabBar.items![1]
        firstButton.isHidden = true
        secondButton.isHidden = true
        headingTextView.text = "Configuring VMWare AirWatch Blocker Screen"
        descriptionTextView.text = "SDK provides the flexibility to configure VMWare AirWatch blue blocker overlay screen which is presented on the double tap of home screen or while app is started and is stopped. Click Learn more to explore!"
    }
    
    func setEditingDLPViews()  {
        currentSelection = 2
        tabBar.selectedItem = tabBar.items![2]
        firstButton.isHidden = true
        secondButton.isHidden = true
        headingTextView.text = "Restrict Cut/Copy/Paste operation"
        descriptionTextView.text = "User shoudln't be able to copy or edit this text if this feature is enabled. SDK can prevent the cut/copy/paste capabilities automatically inside your app. Click Learn more to Explore!"
    }
    
    func setMoreDLPViews()  {
        currentSelection = 3
        self.performSegue(withIdentifier: "segueDLP", sender: self)

    }
    


    
    func alertUser(withMessage customMessage:NSString){
        let alertController = UIAlertController(title: "Data Loss Prevention", message:
            customMessage as String, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Learn More", style: UIAlertActionStyle.default, handler: { (alertAction) -> Void in
            self.performSegue(withIdentifier: "segueDLP", sender: self)
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func setupWalkThroughMaterial()  {
        alertMessageDLP = "Please make sure to define correct bundle settings in your project and enable DLP in the SDK profile on the AW console"
        headingTextView.text = "Restrict data to be opened in AirWatch applications"
        descriptionTextView.text = "SDK Applications can be configured so that HTTP/HTTPS and MAILTO links can be automatically sent to VMware productivity apps.Click Learn more to explore!"
        firstButton.setTitle( "Compose email in VMWare Boxer or inbox App", for: .normal)
        secondButton.setTitle("Open URL in VMWare Browser App", for: .normal)
        
        self.pageAppDLPTitles = NSArray(objects: "Setup bundle in project","Install Productivity apps","Edit SDK Profile", "Enable settings in SDK Profile", "Set the DLP", "Assign the profile")
        self.pageAppDLPImages = NSArray(objects: "EditDLPBundle","InstallProductivityApps","EditSDKProfile","EditDLPInProfile","EnableDLPOptions","AssignSDKProfile")
        
        self.pageOverlayDLPTitles = NSArray(objects: "Setup bundle in project","Blocker View Enabled","Blocker View Disabled")
        self.pageOverlayDLPImages = NSArray(objects: "EditBlockerBundle","WithBlockerScreen","WithoutBlockerScreen")
        
        self.pageEditingDLPTitles = NSArray(objects: "Setup bundle in project","Edit SDK Profile","Edit Settings in SDK Profile","Assign the profile")
        self.pageEditingDLPImages = NSArray(objects: "EditCopyPasteInBundle","EditSDKProfile","EditCopyPasteInProfile","AssignSDKProfile")
        
        self.pageMoreDLPTitles = NSArray(objects: "Additional DLP flags in SDK Profile")
        self.pageMoreDLPImages = NSArray(objects: "MoreDLPSettings")

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        // Create a new variable to store the instance of WalkThthrough View Controller
        let destinationVC = segue.destination as! WalkThroughViewController

        switch currentSelection {
        case 0:
            destinationVC.pageDescription = self.pageAppDLPTitles
            destinationVC.pageMedia = self.pageAppDLPImages
            break
        case 1:
            destinationVC.pageDescription = self.pageOverlayDLPTitles
            destinationVC.pageMedia = self.pageOverlayDLPImages
            break
        case 2:
            destinationVC.pageDescription = self.pageEditingDLPTitles
            destinationVC.pageMedia = self.pageEditingDLPImages
            break
        case 3:
            destinationVC.pageDescription = self.pageMoreDLPTitles
            destinationVC.pageMedia = self.pageMoreDLPImages
            break
        default:
            break
        }
        
        
        
    }
}

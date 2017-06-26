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

class WalkThroughViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageDescription: NSArray!
    var pageMedia: NSArray!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //Setting the Dot based slider
        let pageNavigationController = UIPageControl.appearance()
        pageNavigationController.pageIndicatorTintColor = UIColor.lightGray
        pageNavigationController.currentPageIndicatorTintColor = UIColor.black
        pageNavigationController.backgroundColor = UIColor.white
        
        
        //Instatiating the pageViewController
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as! UIPageViewController
        
        //Attaching the datasource as self
        self.pageViewController.dataSource = self
        
        //This is my custom method which returns refrences to ContentViewController
        //Getting the first ContentViewController
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        
        
        
        let viewControllers = NSArray(object: startVC)
        
        //Setting the viewControllers array as  pageViewController sliders
       self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        
        //Creating a fram in pageViewController
        self.pageViewController.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.size.height - 60)
        
        //Adding the pageViewController as my self child
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartAction(_ sender: AnyObject){
        let startVC = self.viewControllerAtIndex(0) as TutorialViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
    }
    
    //Returning ContentViewController present at the index of the slider
    func viewControllerAtIndex(_ index: Int) -> TutorialViewController{
        
        //If there is no ContentViewController return empty refrences
        if ((self.pageDescription.count == 0) || (index >= self.pageDescription.count)) {
            return TutorialViewController()
        }
    
        //Otherwise instantiating a ContentViewController
        let tutorialViewController: TutorialViewController = self.storyboard?.instantiateViewController(withIdentifier: "tutorialVC") as! TutorialViewController
        
        //Adding text and media to the ContentViewController instance
        tutorialViewController.imageFile = self.pageMedia[index] as! String
        tutorialViewController.titleText = self.pageDescription[index] as! String
        tutorialViewController.pageIndex = index
        
        //return the ContentViewController instance refrence
        return tutorialViewController
        
        
    }
    
    
    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        
        let tutorialViewController = viewController as! TutorialViewController
        var index = tutorialViewController.pageIndex as Int
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
        
    }
    
 
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let tutorialViewController = viewController as! TutorialViewController
        var index = tutorialViewController.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index += 1
        
        if (index == self.pageDescription.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return self.pageDescription.count
    }
    
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        return 0
    }
    
    
}


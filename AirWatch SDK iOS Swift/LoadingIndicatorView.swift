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

class LoadingIndicatorView {
    
    static var BlockerScreen : UIView?
    
    static func show() {
        guard let BlockerWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(BlockerWindow)
    }
    
    static func show(_ _loadingText: String) {
        guard let BlockerWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(BlockerWindow, loadingText: _loadingText)
    }
    
    static func show(_ _callerViewTarget : UIView) {
        show(_callerViewTarget, loadingText: nil)
    }
    
    static func show(_ _callerViewTarget : UIView, loadingText: String?) {
        // Hiding the Blocker if it's already being shown
        hide()
        
        
        //Creaing the Blocker screen
        let localBlocker = UIView(frame: _callerViewTarget.frame)
        localBlocker.center = _callerViewTarget.center
        localBlocker.alpha = 0
        localBlocker.backgroundColor = UIColor.black
        _callerViewTarget.addSubview(localBlocker)
        _callerViewTarget.bringSubview(toFront: localBlocker)
        
        // Setting the Loading Spinner
        let loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadingSpinner.center = localBlocker.center
        loadingSpinner.startAnimating()
        localBlocker.addSubview(loadingSpinner)
        
        // Setting the text for the loading spinner
        if let textString = loadingText {
            let loadingText = UILabel()
            loadingText.text = textString
            loadingText.textColor = UIColor.white
            loadingText.sizeToFit()
            loadingText.center = CGPoint(x: loadingSpinner.center.x, y: loadingSpinner.center.y + 30)
            localBlocker.addSubview(loadingText)
        }
        
        // Showing the blocker and animating
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        localBlocker.alpha = localBlocker.alpha > 0 ? 0 : 0.5
        UIView.commitAnimations()
        
        BlockerScreen = localBlocker
    }
    
    static func hide() {
        if BlockerScreen != nil {
            BlockerScreen?.removeFromSuperview()
            BlockerScreen =  nil
        }
    }
}

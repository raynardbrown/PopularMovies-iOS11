//
//  AppInfoViewController.swift
//
//  Created by Raynard Brown on 2019-07-16.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

// Layout information
//
// - App Info Content View -
//
// The Content View for this view controller that sits right below the root
// view. This view has the following layout properties
//
// Centered within the root view.
// Width set to 300
// Top margin    >= 16
// Bottom margin >= 16
//
// Note: These two margins are either really large or at least 16 which effectively shrinks the
// content view vertically if its child views don't need the extra space.
//
// - Powered By TMDb Logo Image View -
//
// The image view that holds the movie database compliance logo.
//
// Content Mode - Aspect Fit
// Aligned horizontally within the "App Info Content View".
// Leading margin     = 16
// Trailing margin    = 16
// Height            >= 120
//
// Note: The height setting is extremely important because the content mode is set to aspect fit. In
// this mode the image is set to its height/width of the content (the image) while maintaining the
// the aspect ratio. Since we want the image to stretch the width of the "App Info Content View" and
// grow vertically while maintaining the aspect ratio, the a large height value is required since
// autolayout will not do it with leading and trailing margins alone.
//
// - TMDb Disclaimer Label -
//
// Lines set to 0 - for unlimited number of lines
// Leading margin     = 16
// Trailing margin    = 16
// Top margin         = 16 (attached to bottom of "Powered By TMDb Logo Image View")
// Bottom margin      = 16 (attached to bottom of "App Info Content View"

class AppInfoViewController : UIViewController
{
  @IBOutlet var appInfoView: UIView!
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    // add rounded corners to the app info pop up view
    appInfoView.layer.cornerRadius = 15
    
    // lower the opacity of the background color (we use black as a base color and not the view
    // original color of the view controller) for the view controller so that its parent
    // view controller is visible below
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    
    // simple animation that moves the app info up view vertically
    appInfoView.alpha = 0
    self.appInfoView.frame.origin.y = self.appInfoView.frame.origin.y + 50
    UIView.animate(withDuration: 0.4, animations: { () -> Void in
      self.appInfoView.alpha = 1.0;
      self.appInfoView.frame.origin.y = self.appInfoView.frame.origin.y - 50
    })
  }

  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
}

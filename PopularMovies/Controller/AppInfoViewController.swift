//
//  AppInfoViewController.swift
//
//  Created by Raynard Brown on 2019-07-16.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

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

//
//  OrientationChangeDelegate.swift
//
//  Created by Raynard Brown on 2019-06-28.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

protocol OrientationChangeDelegate
{
  func onOrientationChange(_ newOrientation : UIDeviceOrientation)
}

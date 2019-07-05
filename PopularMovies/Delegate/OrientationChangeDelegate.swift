//
//  OrientationChangeDelegate.swift
//
//  Created by Raynard Brown on 2019-06-28.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

protocol OrientationChangeDelegate
{
  /// This function is called when the device changes orientation.
  ///
  /// - Parameter newOrientation: the new orientation of the device.
  func onOrientationChange(_ newOrientation : UIDeviceOrientation)
}

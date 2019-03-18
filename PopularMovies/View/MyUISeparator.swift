//
//  MyUISeparator.swift
//
//  Created by Raynard Brown on 2019-03-17.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

/// An object that displays a divider on the screen.
///
/// This object is used as a visual aid that divides two distinct adjacent sections within a user
/// interface.
///
class MyUISeparator : UIView
{
  /// The width of the separator or -1 if the width is defined by the system.
  private var width : Int = -1
  
  /// The height of this separator or -1 if the height is defined by the system.
  private var height : Int = 1
  
  override open var intrinsicContentSize: CGSize
  {
    return CGSize(width: self.width, height: self.height);
  }
}

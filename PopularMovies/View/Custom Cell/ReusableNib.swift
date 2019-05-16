//
//  ReusableNib.swift
//
//  Created by Raynard Brown on 2019-05-15.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableNib : Reusable
{
  static var nib : UINib { get }
}

extension ReusableNib
{
  static var nib : UINib
  {
    return UINib(nibName: Self.reuseIdentifier, bundle: nil)
  }
}

//
//  Reusable.swift
//
//  Created by Raynard Brown on 2019-05-15.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation

protocol Reusable
{
  static var reuseIdentifier: String { get }
}

extension Reusable
{
  static var reuseIdentifier: String
  {
    return String(describing: Self.self)
  }
}

//
//  FavoriteButtonDelegate.swift
//
//  Created by Raynard Brown on 2019-05-16.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation

protocol FavoriteButtonDelegate
{
  /// Delegate that is triggered when the user clicks the favorite button.
  ///
  /// - Parameter sender: the UIButton that was clicked.
  func onFavoriteButtonClicked(_ sender: Any)
}

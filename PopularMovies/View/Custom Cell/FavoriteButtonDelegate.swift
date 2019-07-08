//
//  FavoriteButtonDelegate.swift
//
//  Created by Raynard Brown on 2019-05-16.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation
import UIKit

protocol FavoriteButtonDelegate
{
  /// Delegate that is triggered when the user clicks the favorite button.
  ///
  /// - Parameters:
  ///   - sender: the UIButton that was clicked.
  ///   - posterImage: the UIImageView that contains the movie poster image.
  func onFavoriteButtonClicked(_ sender: Any,
                               _ posterImage : UIImageView)
}

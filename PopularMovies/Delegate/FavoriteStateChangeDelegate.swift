//
//  FavoriteStateChangeDelegate.swift
//
//  Created by Raynard Brown on 2019-06-02.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

protocol FavoriteStateChangeDelegate
{
  /// Called when the user changes the favorite designation of a movie.
  ///
  func onFavoriteStateChange() -> Void
}

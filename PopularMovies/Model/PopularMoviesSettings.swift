//
//  PopularMoviesSettings.swift
//
//  Created by Raynard Brown on 2019-04-09.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

class PopularMoviesSettings
{
  public static let TOP_RATED : Int = 0
  public static let MOST_POPULAR : Int = 1
  public static let FAVORITES : Int = 2
  
  private var sortSetting : Int
  
  /// Create a new PopularMoviesSettings with the specified sort setting.
  ///
  /// - Parameter sortSetting: specifies the order in which movie posters are displayed within the
  /// main view controller.
  init(_ sortSetting : Int)
  {
    self.sortSetting = sortSetting
  }
  
  func getSortSetting() -> Int
  {
    return self.sortSetting
  }
  
  func setSortSetting(_ sortSetting : Int) -> Void
  {
    self.sortSetting = sortSetting
  }
}

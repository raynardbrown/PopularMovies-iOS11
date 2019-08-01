//
//  UIBarButtonItemEx.swift
//
//  Created by Raynard Brown on 2019-07-27.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

class UIBarButtonItemEx
{
  enum BarButtonLocation
  {
    case RightSide
    case LeftSide
  }
  
  private init()
  {
    
  }
  
  /// Toggle the visibility state of the specified bar button item.
  ///
  /// - Parameters:
  ///   - navItem: The navigation item where the specified bar button item resides.
  ///   - barButtonItem: the bar button item whose visibility state will be toggled.
  ///   - barButtonLocation: the location within the specified navigation item where the specified
  /// bare button item resides.
  ///   - visible: the new visibility state of the specified bar button item. If this parameter is
  /// true then the bar button will become visible within the specified navigation item, it will
  /// become invisible otherwise.
  static func setVisible(_ navItem : UINavigationItem,
                         _ barButtonItem : UIBarButtonItem,
                         _ barButtonLocation : BarButtonLocation,
                         _ visible : Bool)
  {
    var setBarButtonItems : (([UIBarButtonItem]?, Bool) -> Void)! = nil
    var items : [UIBarButtonItem]? = nil
    
    if barButtonLocation == .RightSide
    {
      setBarButtonItems = navItem.setRightBarButtonItems
      items = navItem.rightBarButtonItems
    }
    else
    {
      setBarButtonItems = navItem.setLeftBarButtonItems
      items = navItem.leftBarButtonItems
    }
    
    if visible
    {
      if var items = items
      {
        var foundButton = false
        
        for i in 0..<items.count
        {
          if items[i] == barButtonItem
          {
            foundButton = true
            break
          }
        }
        
        if !foundButton
        {
          // add the button since it's not in the nav bar
          items.append(barButtonItem)
          
          setBarButtonItems(items, true)
        }
      }
    }
    else
    {
      if var items = items
      {
        for i in 0..<items.count
        {
          if items[i] == barButtonItem
          {
            items.remove(at: i)
            
            setBarButtonItems(items, true)
            break
          }
        }
      }
    }
  }
}

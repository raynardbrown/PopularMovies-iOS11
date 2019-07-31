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

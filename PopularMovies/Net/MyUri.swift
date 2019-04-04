//
//  MyUri.swift
//
//  Created by Raynard Brown on 2019-04-02.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation

class MyUri
{
  private var url : URL
  
  init?(_ uriString : String)
  {
    if let temp = URL(string: uriString)
    {
      self.url = temp
    }
    else
    {
      return nil
    }
  }
  
  func appendPath(_ path : String) -> Self
  {
    // TODO: Implement
    
    return self
  }
  
  func appendQueryParameter(_ parameter : String, _ value : String) -> Self
  {
    // TOOD: Implement
    
    return self
  }
  
  func getPathSegments() -> [String]
  {
    // TODO: Implement
    return []
  }
  
  func getQueryParameters() -> [String : String]
  {
    // TODO: Implement
    return [:]
  }
  
}

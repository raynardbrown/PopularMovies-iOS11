//
//  MyUri.swift
//
//  Created by Raynard Brown on 2019-04-02.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation

class MyUri
{
  enum UriComponents
  {
    case SCHEME
    case AUTHORITY
    case PATH
    case QUERY
    case FRAGMENT
  }
  
  private var url : URL
  private var urlComponents : URLComponents
  private var queryParameters : [String : String]
  
  init?(_ uriString : String)
  {
    if let url = URL(string: uriString)
    {
      self.url = url
      
      if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
      {
        self.urlComponents = urlComponents
        
        queryParameters = [:]
      }
      else
      {
        return nil
      }
    }
    else
    {
      return nil
    }
  }
  
  @discardableResult
  func appendPath(_ path : String) -> Self
  {
    url = url.appendingPathComponent(path)
    
    // update the urlComponents
    if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
    {
      self.urlComponents = urlComponents
    }
    
    return self
  }
  
  @discardableResult
  func appendQueryParameter(_ parameter : String, _ value : String) -> Self
  {
    queryParameters[parameter] = value
    
    return self
  }
  
  /// Return a String representation of this MyUri up to and including the specified uriComponents.
  ///
  /// - Parameter uriComponents: the last URI component that will make up the URI returned by this
  /// function.
  /// - Returns: a String that represents the components specified in this MyUri up to and including
  /// the specified uriComponents.
  func getComponentsEndingAt(_ uriComponents : UriComponents) -> String
  {
    var uriString : String = ""

    if let temp = urlComponents.scheme
    {
      uriString.append(temp)
    }

    if(uriComponents == UriComponents.SCHEME)
    {
      return uriString
    }

    if let temp = urlComponents.host
    {
      uriString.append("://\(temp)")
    }

    if(uriComponents == UriComponents.AUTHORITY)
    {
      return uriString
    }

    uriString.append("\(urlComponents.path)")

    if(uriComponents == UriComponents.PATH)
    {
      return uriString
    }
    
    buildQueryItemObjects()

    if let temp = urlComponents.query
    {
      uriString.append("?\(temp)")
    }
    
    if(uriComponents == UriComponents.QUERY)
    {
      return uriString
    }
    
    if let temp = urlComponents.fragment
    {
      uriString.append("#\(temp)")
    }
    
    return uriString
  }
  
  func getPathSegments() -> [String]
  {
    return url.pathComponents
  }
  
  func getQueryParameters() -> [String : String]
  {
    return queryParameters
  }
  
  private func buildQueryItemObjects()
  {
    var queryItems : [URLQueryItem] = []
    for queryPairs in queryParameters
    {
      queryItems.append(URLQueryItem(name: queryPairs.key, value: queryPairs.value))
    }
    
    urlComponents.queryItems = queryItems
  }
}

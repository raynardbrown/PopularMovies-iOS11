//
//  MovieVideoResultObject.swift
//
//  Created by Raynard Brown on 2019-03-18.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

/// Models a movie trailer for a specific movie.
class MovieVideoResultObject
{
  private var id : Int
  
  private var videoClipName : String
  
  private var key : String
  
  
  /// Create a new MovieVideoResultObject object.
  ///
  /// - Parameters:
  ///   - id: the identifier that uniquely identifies the movie associated with this trailer.
  ///   - videoClipName: the title of the movie trailer.
  ///   - key: the ID portion of the path of the URL on YouTube where this trailer is located.
  init(_ id : Int,
       _ videoClipName : String,
       _ key : String)
  {
    self.id = id
    self.videoClipName = videoClipName
    self.key = key
  }
  
  func getId() -> Int
  {
    return id
  }
  
  func setId(_ id : Int) -> Void
  {
    self.id = id
  }
  
  func getVideoClipName() -> String
  {
    return videoClipName
  }
  
  func setVideoClipName(_ videoClipName : String) -> Void
  {
    self.videoClipName = videoClipName
  }
  
  func getKey() -> String
  {
    return key
  }
  
  func setKey(_ key : String) -> Void
  {
    self.key = key
  }
}

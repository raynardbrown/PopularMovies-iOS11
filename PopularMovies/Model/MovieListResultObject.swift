//
//  MovieListResultObject.swift
//
//  Created by Raynard Brown on 2018-07-18.
//  Copyright © 2018 Raynard Brown. All rights reserved.
//

class MovieListResultObject
{
  private var posterPath : String
  private var plotSynopsis : String
  private var releaseDate : String
  private var originalTitle : String
  private var userRating : String
  private var id : Int
  
  /// An object the holds the results of a query to the remote movie data base
  ///
  /// - Parameters:
  ///   - posterPath: the path of the movie poster on the remote server excluding the base URL and
  ///                 size path.
  ///   - plotSynopsis: the synopsis of this movie.
  ///   - releaseDate: the year this movie was released.
  ///   - originalTitle: the title of this movie.
  ///   - userRating: average user rating of this movie.
  ///   - id: an identifier that uniquely identifies this movie in the remote database.
  init(_ posterPath : String,
       _ plotSynopsis : String,
       _ releaseDate : String,
       _ originalTitle : String,
       _ userRating : String,
       _ id : Int)
  {
    self.posterPath = posterPath
    self.plotSynopsis = plotSynopsis
    self.releaseDate = releaseDate
    self.originalTitle = originalTitle
    self.userRating = userRating
    self.id = id
  }
  
  func getPosterPath() -> String
  {
    return posterPath
  }
  
  func getPlotSynopsis() -> String
  {
    return plotSynopsis
  }
  
  func getReleaseDate() -> String
  {
    return releaseDate
  }
  
  func getOriginalTitle() -> String
  {
    return originalTitle
  }
  
  func getUserRating() -> String
  {
    return userRating
  }
  
  func getId() -> Int
  {
    return id
  }
  
  func setId(_ id : Int) -> Void
  {
    self.id = id
  }
}

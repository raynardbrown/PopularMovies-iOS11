//
//  MovieFavoriteObject.swift
//
//  Created by Raynard Brown on 2019-03-23.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

/// Models a movie that a user has marked as its favorite.
class MovieFavoriteObject
{
  private var movieListResultObject : MovieListResultObject
  private var movieVideoResultObjectList : [MovieVideoResultObject]
  private var movieReviewResultObjectList : [MovieReviewResultObject]
  private var moviePosterImageData : [UInt8]
  
  /// Create a new MovieFavoriteObject
  ///
  /// - Parameters:
  ///   - movieListResultObject: the movie associated with this favorite.
  ///   - movieVideoResultObjectList: the collection of movie trailers associated with this movie
  /// favorite.
  ///   - movieReviewResultObjectList: the collection of reviews associated with this movie
  /// favorite.
  ///   - moviePosterImageData: the movie poster image data as an array of bytes.
  init(_ movieListResultObject : MovieListResultObject,
       _ movieVideoResultObjectList : [MovieVideoResultObject],
       _ movieReviewResultObjectList : [MovieReviewResultObject],
       _ moviePosterImageData : [UInt8])
  {
    self.movieListResultObject = movieListResultObject
    self.movieVideoResultObjectList = movieVideoResultObjectList
    self.movieReviewResultObjectList = movieReviewResultObjectList
    self.moviePosterImageData = moviePosterImageData
  }
  
  func getMovieListResultObject() -> MovieListResultObject
  {
    return movieListResultObject
  }
  
  func getMovieVideoResultObjectList() -> [MovieVideoResultObject]
  {
    return movieVideoResultObjectList
  }
  
  func getMovieReviewResultObjectList() -> [MovieReviewResultObject]
  {
    return movieReviewResultObjectList
  }
  
  func getMoviePosterImageData() -> [UInt8]
  {
    return moviePosterImageData
  }
}

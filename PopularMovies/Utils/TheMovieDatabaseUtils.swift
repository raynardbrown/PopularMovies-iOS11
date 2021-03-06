//
//  TheMovieDatabaseUtils.swift
//
//  Created by Raynard Brown on 2018-07-19.
//  Copyright © 2018 Raynard Brown. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TheMovieDatabaseUtils
{
  enum MoviePosterWidths : Int
  {
    case w92 = 92
    case w154 = 154
    case w185 = 185
  }
  
  private init()
  {
    
  }
  
  static func getPopularMoviesUri(_ apiKey : String, _ page : Int) -> MyUri?
  {
    let movieDatabaseGetPopularPath = "popular"
    
    return getMoviesUriHelper(apiKey, page, movieDatabaseGetPopularPath)
  }
  
  static func getTopRatedMoviesUri(_ apiKey : String, _ page : Int) -> MyUri?
  {
    let movieDatabaseGetTopRatedPath = "top_rated"
    
    return getMoviesUriHelper(apiKey, page, movieDatabaseGetTopRatedPath)
  }
  
  static func getVideosMoviesUri(_ apiKey : String, _ page : Int, _ id : Int) -> MyUri?
  {
    let movieDatabaseGetVideosPath = "videos"
    
    return getMoviesUriWithIdHelper(apiKey, page, id, movieDatabaseGetVideosPath)
  }
  
  static func getReviewsMoviesUri(_ apiKey : String, _ page : Int, _ id : Int) -> MyUri?
  {
    let movieDatabaseGetReviewsPath = "reviews"
    
    return getMoviesUriWithIdHelper(apiKey, page, id, movieDatabaseGetReviewsPath)
  }
  
  static func getMoviesUriHelper(_ apiKey : String, _ page : Int, _ path : String) -> MyUri?
  {
    let pageToString = "\(page)"
    
    let movieDatabaseBaseUrl = "https://api.themoviedb.org/3/movie"
    let movieDatabaseApiKeyUrlParameter = "api_key"
    let movieDatabasePageUrlParameter = "page"
    
    if let uri : MyUri = MyUri(movieDatabaseBaseUrl)
    {
      return uri.appendPath(path)
      .appendQueryParameter(movieDatabaseApiKeyUrlParameter, apiKey)
      .appendQueryParameter(movieDatabasePageUrlParameter, pageToString)
    }
    
    return nil
  }
  
  static func getMoviesUriWithIdHelper(_ apiKey : String, _ page : Int, _ id : Int, _ path : String) -> MyUri?
  {
    let idToString = "\(id)"
    let pageToString = "\(page)"
    
    let movieDatabaseBaseUrl = "https://api.themoviedb.org/3/movie"
    let movieDatabaseApiKeyUrlParameter = "api_key"
    let movieDatabasePageUrlParameter = "page"
    
    if let uri : MyUri = MyUri(movieDatabaseBaseUrl)
    {
      return uri.appendPath(idToString)
      .appendPath(path)
      .appendQueryParameter(movieDatabaseApiKeyUrlParameter, apiKey)
      .appendQueryParameter(movieDatabasePageUrlParameter, pageToString)
    }
    
    return nil
  }

  /// Query the movie database using the specified URI. The data from the request is passed to the
  /// specified closure.
  ///
  /// - Parameters:
  ///   - myUri: the URI used to query the movie database.
  ///   - completionHandler: the closure that is called after the movie database is queried.
  ///   - dataResponse: the data from the movie database query that is passed to the specified
  /// closure.
  static func queryTheMovieDatabase(_ myUri : MyUri,
                                    _ completionHandler : @escaping (_ dataResponse : DataResponse<Any>) -> Void)
  {
    let queryBaseUrl = myUri.getComponentsEndingAt(MyUri.UriComponents.PATH)
    let queryParameters = myUri.getQueryParameters()
    
    Alamofire.request(queryBaseUrl, method: .get, parameters: queryParameters).responseJSON
    { (response) in
      
      completionHandler(response)
    }
  }
  
  /// Retrieve the full path of a movie poster from The Movie Database, given the specified poster
  /// base path and specified image width.
  ///
  /// - Parameters:
  ///   - posterPath: the base path of a movie poster image.
  ///   - posterWidth: the width of the movie poster.
  /// - Returns: a complete movie poster image path.
  static func getMoviePosterUriFromPath(_ posterPath : String,
                                        _ posterWidth : MoviePosterWidths) -> String
  {
    let baseUri : String = "https://image.tmdb.org/t/p"
    let imageSizePath = "w\(posterWidth.rawValue)"
    return baseUri + "/" + imageSizePath + posterPath
  }
  
  static func movieJsonToMovieResultArray(_ json : JSON) -> [MovieListResultObject]
  {
    var movieListResultObjectArray : [MovieListResultObject] = [MovieListResultObject]()
    
    let resultsArray = json["results"].arrayValue
    
    if resultsArray.count > 0
    {
      for result in resultsArray
      {
        let posterPath : String = result["poster_path"].stringValue
        
        let plotSynopsis : String = result["overview"].stringValue
        
        let releaseDate : String = result["release_date"].stringValue
        
        let originalTitle : String = result["original_title"].stringValue
        
        let userRatingFloat : Float = result["vote_average"].floatValue
        
        let userRating : String = "\(userRatingFloat)"
        
        let id : Int = result["id"].intValue
        
        movieListResultObjectArray.append(MovieListResultObject(posterPath,
                                                                plotSynopsis,
                                                                releaseDate,
                                                                originalTitle,
                                                                userRating,
                                                                id))
      }
    }
    return movieListResultObjectArray
  }
  
  static func movieVideoJsonStringToMovieVideoResultArray(_ json : JSON, _ id : Int) -> [MovieVideoResultObject]
  {
    let resultsArray = json["results"].arrayValue
    
    var movieVideoResultObjectArray : [MovieVideoResultObject] = [MovieVideoResultObject]()
    
    if resultsArray.count > 0
    {
      for result in resultsArray
      {
        let videoClipName : String = result["name"].stringValue
        
        let key : String = result["key"].stringValue
        
        movieVideoResultObjectArray.append(MovieVideoResultObject(id, videoClipName, key))
      }
    }
    
    return movieVideoResultObjectArray
  }
  
  static func movieReviewJsonStringToMovieReviewResultArray(_ json : JSON, _ id : Int) -> [MovieReviewResultObject]
  {
    let resultsArray = json["results"].arrayValue
    
    var movieReviewResultObjectArray : [MovieReviewResultObject] = [MovieReviewResultObject]()
    
    if resultsArray.count > 0
    {
      for result in resultsArray
      {
        let author : String = result["author"].stringValue
        
        let content : String = result["content"].stringValue
        
        movieReviewResultObjectArray.append(MovieReviewResultObject(id, author, content))
      }
    }
    
    return movieReviewResultObjectArray
  }

} // end TheMovieDatabaseUtils

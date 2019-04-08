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
  private init()
  {
    
  }
  
  static func getPopularMoviesUri(_ apiKey : String, _ page : Int) -> MyUri?
  {
    let movieDatabaseGetPopularPath = "popular"
    
    return getMoviesUriHelper(apiKey, page, movieDatabaseGetPopularPath)
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

  static func queryTheMovieDatabase(_ myUri : MyUri,
                                    _ completionHandler : @escaping ([MovieListResultObject]) -> Void)
  {
    let queryBaseUrl = myUri.getComponentsEndingAt(MyUri.UriComponents.PATH)
    let queryParameters = myUri.getQueryParameters()
    
    Alamofire.request(queryBaseUrl, method: .get, parameters: queryParameters).responseJSON
    { (response) in
      
      if(response.result.isSuccess)
      {
        let resultJson : JSON = JSON(response.result.value!)
        
        let movieResultArray : [MovieListResultObject] = movieJsonToMovieResultArray(resultJson)
        
        // send the movie result array to the completion handler
        completionHandler(movieResultArray)
      }
      else
      {
        // Error getting the movie json data, send an empty array
        completionHandler([MovieListResultObject]())
      }
      
    }
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
        
        let userRating : String = result["vote_average"].stringValue
        
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
  
  static func getMoviePosterUriFromPath(_ posterPath : String) -> String
  {
    let baseUri : String = "https://image.tmdb.org/t/p"
    let imageSizePath = "w185"
    return baseUri + "/" + imageSizePath + posterPath
  }

} // end TheMovieDatabaseUtils

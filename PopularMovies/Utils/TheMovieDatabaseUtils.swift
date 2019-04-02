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

  static func queryTheMovieDatabase(_ queryBaseUrl : String,
                                    _ queryParameters : [String : String],
                                    _ completionHandler : @escaping ([MovieListResultObject]) -> Void)
  {
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

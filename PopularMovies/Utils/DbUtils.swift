//
//  DbUtils.swift
//
//  Created by Raynard Brown on 5/18/19.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import CoreData

class DbUtils
{
  private init()
  {
    
  }
  
  /// Check the favorite database for the movie with the specified identifier.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - movieId: the identifier that uniquely identifies a movie in the favorite database.
  ///   - completionHandler: closure that is called after this database query completes.
  ///   - hasFavorite: true if the movie identified by the specified movie ID was found via this
  /// database query.
  ///   - error: an optional error object if there were any errors during the database query.
  static func queryFavoriteDb(_ context : NSManagedObjectContext,
                              _ movieId : Int,
                              _ completionHandler : (_ hasFavorite : Bool, _ error : Error?) -> Void) -> Void
  {
    let favoriteRequest : NSFetchRequest<MovieFavorite> = MovieFavorite.fetchRequest()
    
    let predicate  = NSPredicate(format: "movie_id == %@", "\(movieId)")
    
    favoriteRequest.predicate = predicate
    
    do
    {
      let favorites = try context.fetch(favoriteRequest)
      
      if favorites.count > 0
      {
        completionHandler(true, nil)
      }
      else
      {
        completionHandler(false, nil)
      }
    }
    catch
    {
      completionHandler(false, error)
    }
  }
  
  /// Save the current changes to the database.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - completionHandler: the closure that is called when the changes have been saved to the
  /// database.
  ///   - error: an optional error object if there were any errors during the database save.
  static func saveDb(_ context : NSManagedObjectContext,
                     _ completionHandler : (_ error : Error?) -> Void) -> Void
  {
    do
    {
      try context.save()
      
      // no errors
      completionHandler(nil)
    }
    catch
    {
      completionHandler(error)
    }
  }
  
  /// Add the movie associated with the specified MovieListResultObject to the favorite database.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - movieListResultObject: the object that describes the movie that will be added to the
  /// favorite database.
  ///   - completionHandler: the closure that is called when the specified movie has been added to
  /// the favorite database.
  ///   - error: an optional error object if there were any errors adding the movie to the database.
  static func addFavorite(_ context : NSManagedObjectContext,
                          _ movieListResultObject : MovieListResultObject,
                          _ completionHandler : (_ error : Error?) -> Void) -> Void
  {
    let movieFavorite : MovieFavorite = MovieFavorite(context: context)
    
    movieFavorite.movie_id = Int32(movieListResultObject.getId())
    
    movieFavorite.movie_plot_synopsis = movieListResultObject.getPlotSynopsis()
    
    // TODO: add the actual image data
    movieFavorite.movie_poster_image_data = Data(bytes: Array<UInt8>())
    
    movieFavorite.movie_poster_url = movieListResultObject.getPosterPath()
    
    movieFavorite.movie_release_date = movieListResultObject.getReleaseDate()
    
    movieFavorite.movie_title = movieListResultObject.getOriginalTitle()
    
    movieFavorite.movie_user_rating = movieListResultObject.getUserRating()
    
    // save the changes
    DbUtils.saveDb(context, completionHandler)
  }
}

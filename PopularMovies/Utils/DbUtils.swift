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
}

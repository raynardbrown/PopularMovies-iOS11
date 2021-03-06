//
//  DbUtils.swift
//
//  Created by Raynard Brown on 5/18/19.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import CoreData
import UIKit

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
  
  /// Check the favorite database for favorites returning any and all that exist.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - completionHandler: closure that is called after this database query completes.
  ///   - movieFavoriteArray: the collection of favorites contained within the favorite database or
  /// an empty array if there are no favorites or there is an error.
  ///   - error: an optional error object if there were any errors during the database query.
  static func queryFavoriteDb(_ context : NSManagedObjectContext,
                              _ completionHandler : (_ movieFavoriteArray : [MovieFavorite],
                                                     _ error : Error?) -> Void) -> Void
  {
    let favoriteRequest : NSFetchRequest<MovieFavorite> = MovieFavorite.fetchRequest()
    
    do
    {
      let favorites = try context.fetch(favoriteRequest)
      
      if favorites.count > 0
      {
        completionHandler(favorites, nil)
      }
      else
      {
        // favorites db is empty
        completionHandler([], nil)
      }
    }
    catch
    {
      completionHandler([], error)
    }
  }
  
  /// Get the image data from the favorite database.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - movieId: the identifier that uniquely identifies a movie in the favorite database.
  ///   - imageView: the image view that will display the image data retrieved from the favorite
  /// database.
  ///   - completionHandler: closure that is called after this database query completes.
  ///   - imageData: the image data retrieved from the database.
  ///   - error: an optional error object if there were any errors during the database query.
  static func queryFavoriteDb(_ context : NSManagedObjectContext,
                              _ movieId : Int,
                              _ imageView : UIImageView,
                              _ completionHandler : (_ imageView : UIImageView,
                                                     _ imageData : Data?,
                                                     _ error : Error?) -> Void) -> Void
  {
    let favoriteRequest : NSFetchRequest<MovieFavorite> = MovieFavorite.fetchRequest()
    
    let predicate  = NSPredicate(format: "movie_id == %@", "\(movieId)")
    
    favoriteRequest.predicate = predicate
    
    do
    {
      let favorites = try context.fetch(favoriteRequest)
      
      if favorites.count > 0
      {
        // no errors, send the image data
        completionHandler(imageView, favorites[0].movie_poster_image_data, nil)
      }
      else
      {
        // no image data in the database, should never happen
        completionHandler(imageView, nil, nil)
      }
    }
    catch
    {
      // error fetching the image data from the database
      completionHandler(imageView, nil, error)
    }
  }
  
  /// Get the image data from the favorite database.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - movieId: the identifier that uniquely identifies a movie in the favorite database.
  /// database.
  ///   - completionHandler: closure that is called after this database query completes.
  ///   - imageData: the image data retrieved from the database.
  ///   - error: an optional error object if there were any errors during the database query.
  static func queryFavoriteDb(_ context : NSManagedObjectContext,
                              _ movieId : Int,
                              _ completionHandler : (_ imageData : Data?,
                                                     _ error : Error?) -> Void) -> Void
  {
    let favoriteRequest : NSFetchRequest<MovieFavorite> = MovieFavorite.fetchRequest()
    
    let predicate  = NSPredicate(format: "movie_id == %@", "\(movieId)")
    
    favoriteRequest.predicate = predicate
    
    do
    {
      let favorites = try context.fetch(favoriteRequest)
      
      if favorites.count > 0
      {
        // no errors, send the image data
        completionHandler(favorites[0].movie_poster_image_data, nil)
      }
      else
      {
        // no image data in the database, should never happen
        completionHandler(nil, nil)
      }
    }
    catch
    {
      // error fetching the image data from the database
      completionHandler(nil, error)
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
  
  /// Check the favorite database for the favorite specified by the movie id returning the favorite
  /// if it exists.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - completionHandler: closure that is called after this database query completes.
  ///   - movieFavorite: the favorite specified by the movie id contained within the favorite
  /// database or nil if the specified favorite does not exist or there is an error.
  ///   - movieTrailers: the trailers associated with the specified movie favorite or an empty array
  /// if the specified movie favorite does not have any trailers associated.
  ///   - movieReviews: the reviews associated with the specified movie favorite or an empty array
  /// if the specified movie favorite does not have any reviews associated.
  ///   - error: an optional error object if there were any errors during the database query.
  static func getFavorite(_ context : NSManagedObjectContext,
                          _ movieId : Int,
                          _ completionHandler : (_ movieFavorite : MovieFavorite?,
                                                 _ movieTrailers : [MovieTrailers],
                                                 _ movieReviews : [MovieReviews],
                                                 _ error : Error?) -> Void) -> Void
  {
    let favoriteRequest : NSFetchRequest<MovieFavorite> = MovieFavorite.fetchRequest()
    
    // match MovieFavorite entity objects that have the movie_id property specified by the parameter
    let formatString = "movie_id == %@"
    
    let predicate  = NSPredicate(format: formatString, "\(movieId)")
    
    favoriteRequest.predicate = predicate
    
    do
    {
      let favoriteFetch = try context.fetch(favoriteRequest)
      
      if favoriteFetch.count > 0
      {
        let favorite = favoriteFetch[0]
        
        // fetch trailers
        let trailerRequest : NSFetchRequest<MovieTrailers> = MovieTrailers.fetchRequest()
        
        trailerRequest.predicate = predicate
        
        let trailers = try context.fetch(trailerRequest)
        
        // fetch reviews
        let reviewRequest : NSFetchRequest<MovieReviews> = MovieReviews.fetchRequest()
        
        reviewRequest.predicate = predicate
        
        let reviews = try context.fetch(reviewRequest)
        
        completionHandler(favorite, trailers, reviews, nil)
      }
      else
      {
        // favorites db is empty
        completionHandler(nil, [], [], nil)
      }
    }
    catch
    {
      completionHandler(nil, [], [], error)
    }
  }

  /// Add the movie associated with the specified MovieListResultObject to the favorite database.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - movieListResultObject: the object that describes the movie that will be added to the
  ///   - movieVideoResultObjectArray: the collection of trailers associated with the specified
  /// movie that will be saved to the favorite database.
  ///   - movieReviewResultObjectArray: the collection of reviews associated with the specified
  /// movie that will be saved to the favorite database.
  ///   - imageData: the movie poster image data.
  ///   - completionHandler: the closure that is called when the specified movie has been added to
  /// the favorite database.
  ///   - error: an optional error object if there were any errors adding the movie to the database.
  static func addFavorite(_ context : NSManagedObjectContext,
                          _ movieListResultObject : MovieListResultObject,
                          _ movieVideoResultObjectArray : [MovieVideoResultObject],
                          _ movieReviewResultObjectArray : [MovieReviewResultObject],
                          _ imageData : Data,
                          _ completionHandler : (_ error : Error?) -> Void) -> Void
  {
    let movieFavorite : MovieFavorite = MovieFavorite(context: context)
    
    let movieId = Int32(movieListResultObject.getId())
    
    movieFavorite.movie_id = Int32(movieId)
    
    movieFavorite.movie_plot_synopsis = movieListResultObject.getPlotSynopsis()
    
    // add the image data
    movieFavorite.movie_poster_image_data = imageData
    
    movieFavorite.movie_poster_url = movieListResultObject.getPosterPath()
    
    movieFavorite.movie_release_date = movieListResultObject.getReleaseDate()
    
    movieFavorite.movie_title = movieListResultObject.getOriginalTitle()
    
    movieFavorite.movie_user_rating = movieListResultObject.getUserRating()
    
    // add the trailers
    for movieVideoResultObject in movieVideoResultObjectArray
    {
      let movieTrailer : MovieTrailers = MovieTrailers(context: context)
      
      movieTrailer.movie_id = movieId
      
      movieTrailer.trailer_clip_title = movieVideoResultObject.getVideoClipName()
      
      movieTrailer.trailer_youtube_key = movieVideoResultObject.getKey()
    }
    
    // add the reviews
    for movieReviewResultObject in movieReviewResultObjectArray
    {
      let movieReview : MovieReviews = MovieReviews(context: context)
      
      movieReview.movie_id = movieId
      
      movieReview.review_author = movieReviewResultObject.getAuthor()
      
      movieReview.review_content = movieReviewResultObject.getReviewContent()
    }
    
    // save the changes
    DbUtils.saveDb(context, completionHandler)
  }

  /// Remove the movie associated with the specified MovieListResultObject from the favorite
  /// database.
  ///
  /// - Parameters:
  ///   - context: the database context.
  ///   - movieListResultObject: the object that describes the movie that will be removed from the
  /// favorite database.
  ///   - completionHandler: the closure that is called when the specified movie has been removed
  /// from the favorite database.
  ///   - error: an optional error object if there were any errors removing the movie to the
  /// database.
  static func removeFavorite(_ context : NSManagedObjectContext,
                             _ movieListResultObject : MovieListResultObject,
                             _ completionHandler : (_ error : Error?) -> Void) -> Void
  {
    let favoriteRequest : NSFetchRequest<MovieFavorite> = MovieFavorite.fetchRequest()
    
    // match MovieFavorite entity objects that have the movie_id property specified by the parameter
    let formatString = "movie_id == %@"
    
    let predicate  = NSPredicate(format: formatString, "\(movieListResultObject.getId())")
    
    favoriteRequest.predicate = predicate
    
    do
    {
      let favorites = try context.fetch(favoriteRequest)
      
      if favorites.count > 0
      {
        context.delete(favorites[0])
        
        // Remove the trailers
        let trailerRequest : NSFetchRequest<MovieTrailers> = MovieTrailers.fetchRequest()
        
        trailerRequest.predicate = predicate
        
        let trailers = try context.fetch(trailerRequest)
        
        for trailer in trailers
        {
          context.delete(trailer)
        }
        
        // Remove the reviews
        let reviewRequest : NSFetchRequest<MovieReviews> = MovieReviews.fetchRequest()
        
        reviewRequest.predicate = predicate
        
        let reviews = try context.fetch(reviewRequest)
        
        for review in reviews
        {
          context.delete(review)
        }
        
        // save the database
        DbUtils.saveDb(context, completionHandler)
      }
      else
      {
        // movie is not in the database
        
        // major error (we are in an inconsistent UI state) if the favorite is not in the database
        // TODO: We should handle this but for now just log the error
        print("Error deleting favorite, favorite not in the database")
      }
    }
    catch
    {
      // Error fetching movie favorite data from context
      completionHandler(error)
    }
  }
}

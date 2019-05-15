//
//  MovieReviewResultObject.swift
//
//  Created by Raynard Brown on 2019-02-28.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

/// MovieReviewResultObject is an object that models a review for a specific movie.
class MovieReviewResultObject
{
  private var id : Int
  private var author : String
  private var reviewContent : String
  
  /// Create a new MovieReviewResultObject.
  ///
  /// - Parameters:
  ///   - id: the identifier that uniquely identifies the movie associated with this review.
  ///   - author: the author that wrote this review.
  ///   - reviewContent: the review contents.
  init(_ id : Int,
       _ author : String,
       _ reviewContent : String)
  {
    self.id = id
    self.author = author
    self.reviewContent = reviewContent
  }
  
  func getId() -> Int
  {
    return id
  }
  
  func getAuthor() -> String
  {
    return author
  }
  
  func getReviewContent() -> String
  {
    return reviewContent
  }
  
  func setId(_ id : Int) -> Void
  {
    self.id = id
  }
  
  func setAuthor(_ author : String) -> Void
  {
    self.author = author
  }
  
  func setReviewContent(_ reviewContent : String) -> Void
  {
    self.reviewContent = reviewContent
  }
}

//
//  MoviePosterDetailViewController.swift
//
//  Created by Raynard Brown on 2019-03-10.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit
import CoreData

import Alamofire
import SDWebImage
import SwiftyJSON

/// A view controller that displays a detailed view of the poster that was clicked from the main
/// view controller.
class MoviePosterDetailViewController : UIViewController,
                                        UITableViewDelegate,
                                        UITableViewDataSource,
                                        FavoriteButtonDelegate
{
  enum FavoriteState
  {
    case Favorite
    case Unfavorite
    case Indeterminate
  }

  var movieListResultObject : MovieListResultObject!

  var movieVideoResultObjectArray : [MovieVideoResultObject] = [MovieVideoResultObject]()

  var movieReviewResultObjectArray : [MovieReviewResultObject] = [MovieReviewResultObject]()

  var favoriteState : FavoriteState = MoviePosterDetailViewController.FavoriteState.Indeterminate

  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  @IBOutlet var mainTableView: UITableView!

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.title = "Movie Detail"
    
    self.mainTableView.delegate = self
    self.mainTableView.dataSource = self
    
    // register the main cell
    mainTableView.register(CustomMainDetailViewTableViewCell.nib,
                           forCellReuseIdentifier: CustomMainDetailViewTableViewCell.reuseIdentifier)
    
    // register generic header
    mainTableView.register(DetailViewTableHeader.nib,
                           forHeaderFooterViewReuseIdentifier: DetailViewTableHeader.reuseIdentifier)
    
    // register the error/empty cell
    mainTableView.register(EmptyDetailViewTableViewCell.nib,
                           forCellReuseIdentifier: EmptyDetailViewTableViewCell.reuseIdentifier)
    
    // register the trailer cell
    mainTableView.register(CustomMovieTrailerTableViewCell.nib,
                           forCellReuseIdentifier: CustomMovieTrailerTableViewCell.reuseIdentifier)
    
    // register the review cell
    mainTableView.register(CustomMovieReviewTableViewCell.nib,
                           forCellReuseIdentifier: CustomMovieReviewTableViewCell.reuseIdentifier)
    
    configureTableView()
    
    fetchTrailers()
    
    fetchReviews()
    
    DbUtils.queryFavoriteDb(context, movieListResultObject.getId(), onQueryDb)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int
  {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    if section == 0
    {
      return 1
    }
    
    if section == 1 && movieVideoResultObjectArray.count > 0
    {
      return movieVideoResultObjectArray.count
    }
    
    if section == 2 && movieReviewResultObjectArray.count > 0
    {
      return movieReviewResultObjectArray.count
    }
    
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
  {
    if section == 0
    {
      return CGFloat.leastNonzeroMagnitude // the main section has no header
    }
    
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
  {
    if section == 1
    {
      let header = self.mainTableView.dequeueReusableHeaderFooterView(withIdentifier: DetailViewTableHeader.reuseIdentifier) as! DetailViewTableHeader
      
      header.headerLabel.text = "Trailers:"
      
      return header
    }
    
    if section == 2
    {
      let header = self.mainTableView.dequeueReusableHeaderFooterView(withIdentifier: DetailViewTableHeader.reuseIdentifier) as! DetailViewTableHeader
      
      header.headerLabel.text = "Reviews:"
      
      return header
    }
    
    return nil
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let section : Int = indexPath.section
    
    let index : Int = indexPath.row
    
    var cell : UITableViewCell?
    
    if section == 0
    {
      // the main section only has one row so there is no need to check the index
      
      let tempCell = tableView.dequeueReusableCell(withIdentifier: CustomMainDetailViewTableViewCell.reuseIdentifier,
                                                   for: indexPath) as! CustomMainDetailViewTableViewCell
      
      cell = updateMainCell(tempCell)
    }
    
    if section == 1
    {
      if movieVideoResultObjectArray.count > 0
      {
        let tempCell = tableView.dequeueReusableCell(withIdentifier: CustomMovieTrailerTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! CustomMovieTrailerTableViewCell
      
        tempCell.movieTrailerTitleLabel.text = movieVideoResultObjectArray[index].getVideoClipName()
      
        cell = tempCell
      }
      else
      {
        let tempCell = tableView.dequeueReusableCell(withIdentifier: EmptyDetailViewTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! EmptyDetailViewTableViewCell
        
        tempCell.emptyCellLabel.text = "No Trailers Here"
        
        cell = tempCell
      }
    }
    
    if section == 2
    {
      if movieReviewResultObjectArray.count > 0
      {
        let tempCell = tableView.dequeueReusableCell(withIdentifier: CustomMovieReviewTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! CustomMovieReviewTableViewCell
        
        tempCell.reviewAuthor.text = movieReviewResultObjectArray[index].getAuthor()
        
        tempCell.reviewText.text = movieReviewResultObjectArray[index].getReviewContent()
        
        cell = tempCell
      }
      else
      {
        let tempCell = tableView.dequeueReusableCell(withIdentifier: EmptyDetailViewTableViewCell.reuseIdentifier,
                                                     for: indexPath) as! EmptyDetailViewTableViewCell
        
        tempCell.emptyCellLabel.text = "No Reviews Here"
        
        cell = tempCell
      }
    }
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
  {
    let index : Int = indexPath.row
    
    if index == 0
    {
      // disable selecting the first row when clicked
      return nil
    }
    
    return indexPath
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
  {
    let section : Int = indexPath.section
    
    if section == 0
    {
      // disable highlighting the main section when clicked
      return false
    }
    
    return true
  }
  
  func configureTableView() -> Void
  {
    // ensure that the table view separator extends the length of a table cell
    mainTableView.separatorInset = .zero
    
    mainTableView.rowHeight = UITableViewAutomaticDimension
    mainTableView.estimatedRowHeight = 61
    
    // set up estimated heights for the section headers within the table view
    mainTableView.sectionHeaderHeight = UITableViewAutomaticDimension
    mainTableView.estimatedSectionHeaderHeight = 50
    
    // remove additional separator lines at the bottom of the table view
    // in additional there is a small gap at the bottom of the table view that is removed
    mainTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    
    // Remove the gaps at bottom of each sections (iOS bug?)
    mainTableView.sectionFooterHeight = 0.0
  }
  
  func updateMainCell(_ cell : CustomMainDetailViewTableViewCell) -> UITableViewCell
  {
    cell.moviePosterTitleLabel.text = movieListResultObject.getOriginalTitle()
    
    let moviePosterRelativePath : String = movieListResultObject.getPosterPath()
    
    let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(moviePosterRelativePath)
    
    cell.moviePosterImage.sd_setImage(with: URL(string: moviePosterPath),
                                      placeholderImage : UIImage(named: "image_placeholder.png"))
    
    cell.moviePosterReleaseDateLabel.text = movieListResultObject.getReleaseDate()
    
    cell.moviePosterUserRatingLabel.text = movieListResultObject.getUserRating()
    
    cell.moviePosterDescriptionLabel.text = movieListResultObject.getPlotSynopsis()
    
    if favoriteState == .Favorite
    {
      cell.moviePosterFavoriteButton.setTitle("Favorite", for: .normal)
      
      cell.moviePosterFavoriteButton.isHidden = false
    }
    else if favoriteState == .Unfavorite
    {
      cell.moviePosterFavoriteButton.setTitle("Unfavorite", for: .normal)
      
      cell.moviePosterFavoriteButton.isHidden = false
    }
    else
    {
      cell.moviePosterFavoriteButton.isHidden = true
    }
    
    cell.favoriteButtonDelegate = self
    
    return cell
  }
  
  func fetchTrailers() -> Void
  {
    let theMovieDatabaseApiKey = PopularMoviesConstants.getTheMovieDatabaseApiKey()
    let page : Int = 1
    
    if let myUri = TheMovieDatabaseUtils.getVideosMoviesUri(theMovieDatabaseApiKey, page, movieListResultObject.getId())
    {
      TheMovieDatabaseUtils.queryTheMovieDatabase(myUri, onTrailerResults)
    }
  }
  
  func fetchReviews() -> Void
  {
    let theMovieDatabaseApiKey = PopularMoviesConstants.getTheMovieDatabaseApiKey()
    let page : Int = 1
    
    if let myUri = TheMovieDatabaseUtils.getReviewsMoviesUri(theMovieDatabaseApiKey, page, movieListResultObject.getId())
    {
      TheMovieDatabaseUtils.queryTheMovieDatabase(myUri, onReviewsResults)
    }
  }
  
  func onTrailerResults(movieTrailerResultsResponse : DataResponse<Any>)
  {
    if(movieTrailerResultsResponse.result.isSuccess)
    {
      let resultJson : JSON = JSON(movieTrailerResultsResponse.result.value!)
      
      let movieTrailerResultArray : [MovieVideoResultObject] = TheMovieDatabaseUtils.movieVideoJsonStringToMovieVideoResultArray(resultJson,
                                                                                                                                 movieListResultObject.getId())
      
      movieVideoResultObjectArray = movieTrailerResultArray
      
      mainTableView.reloadData()
    }
    else
    {
      // TODO: handle failure
    }
  }
  
  func onReviewsResults(movieReviewResultsResponse : DataResponse<Any>)
  {
    if(movieReviewResultsResponse.result.isSuccess)
    {
      let resultJson : JSON = JSON(movieReviewResultsResponse.result.value!)
      
      let movieReviewResultArray : [MovieReviewResultObject] = TheMovieDatabaseUtils.movieReviewJsonStringToMovieReviewResultArray(resultJson,
                                                                                                                                 movieListResultObject.getId())
      
      movieReviewResultObjectArray = movieReviewResultArray
      
      mainTableView.reloadData()
    }
    else
    {
      // TODO: handle failure
    }
  }
  
  func onFavoriteButtonClicked(_ sender: Any)
  {
    if favoriteState == .Favorite
    {
      // add favorite (add movie to database)
      DbUtils.addFavorite(context, movieListResultObject,
      { (error) in
        
        if let error = error
        {
          print("Error saving favorite to database \(error)")
        }
        else
        {
          // update the favorite button
          favoriteState = .Unfavorite
            
          mainTableView.reloadData()
        }
      })
    }
    else
    {
      // remove favorite (remove movie from database)
      DbUtils.removeFavorite(context, movieListResultObject,
      { (error) in
        
        if let error = error
        {
          print("Error removing favorite from database \(error)")
        }
        else
        {
          // update the favorite button
          favoriteState = .Favorite
          
          mainTableView.reloadData()
        }
      })
    }
  }
  
  func onQueryDb(_ hasFavorite : Bool, _ error : Error?) -> Void
  {
    if let error = error
    {
      print("Error fetching favorite data from context \(error)")
    }
    else
    {
      // no errors
      
      if hasFavorite
      {
        // this movie is a favorite, that means the button needs to be unfavorite
        
        favoriteState = .Unfavorite
        
        mainTableView.reloadData()
      }
      else
      {
        // this movie is not a favorite, that means the button needs to be favorite
        
        favoriteState = .Favorite
        
        mainTableView.reloadData()
      }
    }
  }

  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
}

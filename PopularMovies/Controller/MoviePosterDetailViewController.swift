//
//  MoviePosterDetailViewController.swift
//
//  Created by Raynard Brown on 2019-03-10.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation
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
  
  enum Sections : Int
  {
    case MainSection = 0
    case TrailerSection
    case ReviewSection
    case count
  }

  var movieListResultObject : MovieListResultObject!
  
  var posterWidth : TheMovieDatabaseUtils.MoviePosterWidths!

  var movieVideoResultObjectArray : [MovieVideoResultObject] = [MovieVideoResultObject]()

  var movieReviewResultObjectArray : [MovieReviewResultObject] = [MovieReviewResultObject]()

  var favoriteState : FavoriteState = MoviePosterDetailViewController.FavoriteState.Indeterminate

  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var favoriteStateChangeDelegate : FavoriteStateChangeDelegate?
  
  var orientationChangeDelegate : OrientationChangeDelegate!
  
  var queryTaskComplete : Bool = false
  
  var trailerTaskComplete : Bool = false
  
  var reviewTaskComplete : Bool = false
  
  var moviePosterLoadingComplete : Bool = false
  
  var showFavoriteButton : Bool = false
  
  var enableShareButton : Bool = false
  
  var moviePosterImage : UIImage? = nil
  
  var moviePosterImageView : UIImageView = UIImageView()
  
  var moviePosterImageData : Data? = nil

  @IBOutlet var mainTableView: UITableView!
  @IBOutlet var shareButton: UIBarButtonItem!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.title = "Movie Detail"
    
    self.mainTableView.delegate = self
    self.mainTableView.dataSource = self
    
    // clear the title from the bar button so that the text does not show from the behind the image
    shareButton.title = ""
    
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
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    // register for the orientation change notification
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(MoviePosterDetailViewController.onRotation),
                                           name: NSNotification.Name.UIDeviceOrientationDidChange,
                                           object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)
    
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name.UIDeviceOrientationDidChange,
                                              object: nil)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int
  {
    return Sections.count.rawValue
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    let sectionAsEnum : Sections = Sections(rawValue: section)!

    if sectionAsEnum == .MainSection
    {
      return 1
    }
    
    if sectionAsEnum == .TrailerSection && movieVideoResultObjectArray.count > 0
    {
      return movieVideoResultObjectArray.count
    }
    
    if sectionAsEnum == .ReviewSection && movieReviewResultObjectArray.count > 0
    {
      return movieReviewResultObjectArray.count
    }
    
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
  {
    let sectionAsEnum : Sections = Sections(rawValue: section)!
    
    if sectionAsEnum == .MainSection
    {
      return CGFloat.leastNonzeroMagnitude // the main section has no header
    }
    
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
  {
    let sectionAsEnum : Sections = Sections(rawValue: section)!
    
    if sectionAsEnum == .TrailerSection
    {
      let header = self.mainTableView.dequeueReusableHeaderFooterView(withIdentifier: DetailViewTableHeader.reuseIdentifier) as! DetailViewTableHeader
      
      header.headerLabel.text = "Trailers:"
      
      return header
    }
    
    if sectionAsEnum == .ReviewSection
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
    
    let sectionAsEnum : Sections = Sections(rawValue: section)!
    
    let index : Int = indexPath.row
    
    var cell : UITableViewCell?
    
    if sectionAsEnum == .MainSection
    {
      // the main section only has one row so there is no need to check the index
      
      let tempCell = tableView.dequeueReusableCell(withIdentifier: CustomMainDetailViewTableViewCell.reuseIdentifier,
                                                   for: indexPath) as! CustomMainDetailViewTableViewCell
      
      cell = updateMainCell(tempCell)
    }
    
    if sectionAsEnum == .TrailerSection
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
    
    if sectionAsEnum == .ReviewSection
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
    let section : Int = indexPath.section
    
    let sectionAsEnum : Sections = Sections(rawValue: section)!
    
    if sectionAsEnum == .MainSection || sectionAsEnum == .ReviewSection
    {
      // disable selecting the main and review section when clicked
      
      // we do not need to check the index too because there is only one row in our main section
      return nil
    }
    
    return indexPath
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
  {
    let section : Int = indexPath.section
    
    let sectionAsEnum : Sections = Sections(rawValue: section)!
    
    if sectionAsEnum == .MainSection || sectionAsEnum == .ReviewSection
    {
      // disable highlighting the main and review section when clicked
      
      // we do not need to check the index too because there is only one row in our main section
      return false
    }
    
    return true
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    let section : Int = indexPath.section
    
    let sectionAsEnum : Sections = Sections(rawValue: section)!
    
    let index : Int = indexPath.row
    
    if sectionAsEnum == .TrailerSection
    {
      let youTubeKey : String = movieVideoResultObjectArray[index].getKey()
      
      openVideoOnYouTubeInBrowser(youTubeKey)
      
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  /// Display the YouTube video specified by video key, in a web browser.
  ///
  /// - Parameter videoKey: the key that uniquely identifies a YouTube video.
  func openVideoOnYouTubeInBrowser(_ videoKey : String)
  {
    let youtube_website_base_url = "https://www.youtube.com/watch"
    
    if let uri : MyUri = MyUri(youtube_website_base_url)
    {
      uri.appendQueryParameter("v", videoKey)
      
      if let url = URL(string: uri.getComponentsEndingAt(MyUri.UriComponents.QUERY))
      {
        if #available(iOS 10.0, *)
        {
          UIApplication.shared.open(url, options: [:], completionHandler : nil)
        }
        else
        {
          UIApplication.shared.openURL(url)
        }
      }
    }
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
    
    if #available(iOS 11.0, *)
    {
      // the default setting
      self.automaticallyAdjustsScrollViewInsets = true;
    }
    else
    {
      // this is needed on platforms less than iOS 11 (i.e. iOS 10)
      // On those platforms, iOS adds a empty header at the top of the table view
      self.automaticallyAdjustsScrollViewInsets = false;
    }
  }
  
  func updateMainCell(_ cell : CustomMainDetailViewTableViewCell) -> UITableViewCell
  {
    cell.moviePosterTitleLabel.text = movieListResultObject.getOriginalTitle()
    
    let moviePosterRelativePath : String = movieListResultObject.getPosterPath()
    
    let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(moviePosterRelativePath,
                                                                                   posterWidth)
    
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
  
  func onFavoriteButtonClicked(_ sender: Any, _ posterImageView : UIImageView)
  {
    if favoriteState == .Favorite
    {
      if let posterImage = posterImageView.image
      {
        if let imageData = UIImagePNGRepresentation(posterImage)
        {
          // add favorite (add movie to database)
          DbUtils.addFavorite(context,
                              movieListResultObject,
                              movieVideoResultObjectArray,
                              movieReviewResultObjectArray,
                              imageData,
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
      }
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
    
    favoriteStateChangeDelegate?.onFavoriteStateChange()
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

  @IBAction func onShareButtonClicked(_ sender: Any)
  {
    let youtube_website_base_url = "https://www.youtube.com/watch"
    
    if movieVideoResultObjectArray.count > 0
    {
      let videoKey = movieVideoResultObjectArray[0].getKey()
      
      if let uri : MyUri = MyUri(youtube_website_base_url)
      {
        uri.appendQueryParameter("v", videoKey)
        
        let uriAsString = uri.getComponentsEndingAt(MyUri.UriComponents.QUERY)
        
        if let url = NSURL(string: uriAsString)
        {
          // share the URL as text and as a URL
          let shareData : [Any] = [uriAsString, url]
        
          let activityViewController = UIActivityViewController(activityItems: shareData, applicationActivities: nil)
        
          activityViewController.popoverPresentationController?.sourceView = self.view
        
          // show
          self.present(activityViewController, animated: true, completion: nil)
        }
      }
    }
  }
  
  @objc
  func onRotation()
  {
    let isLandscape = UIDevice.current.orientation.isLandscape
    let isPortrait = UIDevice.current.orientation == .portrait
    
    if isLandscape
    {
      // We are in landscape mode
      self.orientationChangeDelegate.onOrientationChange(.landscapeLeft)
    }
    else if isPortrait
    {
      // We are in portrait mode
      self.orientationChangeDelegate.onOrientationChange(.portrait)
    }
  }
  
  func onAllTasksComplete() -> Void
  {
    // it's safe to show the favorite button now
    showFavoriteButton = true
    
    mainTableView.reloadData()
  }
  
  func notifyTaskComplete() -> Void
  {
    if queryTaskComplete &&
       reviewTaskComplete &&
       trailerTaskComplete &&
       moviePosterLoadingComplete
    {
      onAllTasksComplete()
    }
    
    UIBarButtonItemEx.setVisible(self.navigationItem, shareButton, .RightSide, enableShareButton)
  }

  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
}

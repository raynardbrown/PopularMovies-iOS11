//
//  ViewController.swift
//
//  Created by Raynard Brown on 2018-07-06.
//  Copyright © 2018 Raynard Brown. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON

/// The main entry point for this application. This view controller displays a collection of movie
/// posters from a local or remote database. Clicking on a movie poster launches a detailed view
/// controller for the clicked movie poster.
class MainViewController : UIViewController,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout,
                           FavoriteStateChangeDelegate,
                           OrientationChangeDelegate,
                           NetworkStateDelegate
{
  @IBOutlet var moviePosterCollectionView: UICollectionView!
  
  // Gives us access to the itemSize property
  @IBOutlet var moviePosterCollectionViewFlowLayout: UICollectionViewFlowLayout!
  @IBOutlet var infoBarButtonItem: UIBarButtonItem!
  @IBOutlet var sortBarButtonItem: UIBarButtonItem!
  
  private var movieListResultObjectArray : [MovieListResultObject] = [MovieListResultObject]()
  
  private let appTitle : String = "Popular Movies"
  
  private var popularMoviesSettings : PopularMoviesSettings!
  
  static let LaunchMoviePosterDetailView : String = "launchMoviePosterDetailView"
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  private var favoritesChange : Bool = false
  
  private var dispatchedTriggered : Bool = false
  
  private var orientationHandled : Bool = true
  
  private var itemSize : CGSize = CGSize(width: 0, height: 0)
  
  private var posterWidth : TheMovieDatabaseUtils.MoviePosterWidths!
  
  // When we first start assume we are in portrait mode.
  private var lastOrientation : UIDeviceOrientation = .portrait
  
  private var actualOrientation : UIDeviceOrientation?
  
  private var networkStateMonitor : NetworkStateMonitor!
  
  /// Is there a network connection available. The initial state is false until a network connection
  /// check is initiated.
  private var isConnected : Bool = false
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Set up the delegate and data source for the collection view
    moviePosterCollectionView.delegate = self
    moviePosterCollectionView.dataSource = self
    
    // clear the title from the bar button so that the text does not show from the behind the image
    // Note: title must be nil not the empty string otherwise on certain platforms (iOS 10) the
    //       bar button icons will be displayed between the nav bar and the main content view.
    infoBarButtonItem.title = nil
    sortBarButtonItem.title = nil
    
    // default sort setting
    popularMoviesSettings = PopularMoviesSettings(PopularMoviesSettings.MOST_POPULAR)
    
    moviePosterCollectionView.register(MovieCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
    
    // register the no favorites error message
    moviePosterCollectionView.register(NoFavoritesCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: NoFavoritesCollectionViewCell.reuseIdentifier)
    
    // register the no network error message
    moviePosterCollectionView.register(NoNetworkConnectionCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: NoNetworkConnectionCollectionViewCell.reuseIdentifier)
    
    configureCollectionView()
    
    // Hold off on calling dispatchMovieListResultRequest. We want to want until we've had a chance
    // to do the follow
    //
    // 1) Get our initial orientation.
    //
    // 2) Calculate the size of the collection view cells.
    
    networkStateMonitor = NetworkStateMonitor(self)
  }

  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    
    // Ensure the navigation title is displayed when we navigate back from the child view
    // TODO: Fix this so that the animation transitions smoothly
    self.navigationItem.title = appTitle
    
    // register for the orientation change notification
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(MainViewController.onRotation),
                                           name: NSNotification.Name.UIDeviceOrientationDidChange,
                                           object: nil)
    
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if setting == PopularMoviesSettings.FAVORITES
    {
      if favoritesChange
      {
        // reset the movie list array
        movieListResultObjectArray = [MovieListResultObject]()
        
        // ensure we reload the tableview to prevent the table view using the old movie list count
        moviePosterCollectionView.reloadData()
        
        fetchFavorites()
        
        favoritesChange = false
      }
      else
      {
        // even if the favorites don't change, make sure we detect and handle a rotation if
        // necessary. We do not need to call onRotation if the favorites change, because the data
        // is cleared and reloaded.
        onRotation()
      }
    }
    else
    {
      onRotation()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int
  {
    if isFavoriteErrorState() ||
       isNetworkErrorState()
    {
      // we are in the favorite state but the favorite database is empty
      
      // or we don't have a network connection and we have not downloaded any movie posters yet
      return 1
    }
    
    return movieListResultObjectArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    if isFavoriteErrorState()
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoFavoritesCollectionViewCell.reuseIdentifier,
                                                    for: indexPath) as! NoFavoritesCollectionViewCell
      
      return cell
    }
    else if isNetworkErrorState()
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoNetworkConnectionCollectionViewCell.reuseIdentifier,
                                                    for: indexPath) as! NoNetworkConnectionCollectionViewCell
      
      return cell
    }
    else
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier,
                                                    for: indexPath) as! MovieCollectionViewCell
    
      let moviePosterRelativePath : String = movieListResultObjectArray[indexPath.row].getPosterPath()
    
      let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(moviePosterRelativePath,
                                                                                     posterWidth)
      
      if popularMoviesSettings.getSortSetting() == PopularMoviesSettings.FAVORITES
      {
        // set the place holder for now and populate the imageView with the image data from the
        // favorite database.
        
        cell.movieCollectionImageView.image = UIImage(named: "image_placeholder.png")
        
        let movieId : Int = movieListResultObjectArray[indexPath.row].getId()
        
        DbUtils.queryFavoriteDb(context,
                                movieId,
                                cell.movieCollectionImageView,
                                onQueryDb)
      }
      else
      {
        cell.movieCollectionImageView.sd_setImage(with: URL(string: moviePosterPath),
                                                  placeholderImage : UIImage(named: "image_placeholder.png"))
      }
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    if !isFavoriteErrorState() &&
       !isNetworkErrorState()
    {
      let movieListResultObject : MovieListResultObject = movieListResultObjectArray[indexPath.row]
      
      performSegue(withIdentifier: MainViewController.LaunchMoviePosterDetailView,
                   sender: movieListResultObject)
    }
  }
  
  override func viewDidLayoutSubviews()
  {
    super.viewDidLayoutSubviews()
  
    // we need to force a call to onRotation in case the user is holding the phone in portrait mode
    // not face up/down and they launch the app. In this case the onRotation call is not triggered
    // during initialization like we expect.
    onRotation()
    
    // check to see if we have updated the collection view after the user rotated the device
    if !orientationHandled
    {
      orientationHandled = true
      
      moviePosterCollectionView.collectionViewLayout.invalidateLayout()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    if isFavoriteErrorState() ||
       isNetworkErrorState()
    {
      // the no favorites or no network error message should fill the size of the collection view
      return collectionView.frame.size
    }

    return itemSize
  }
  
  func configureCollectionView() -> Void
  {
    if #available(iOS 11.0, *)
    {
      // the default setting
      self.automaticallyAdjustsScrollViewInsets = true;
    }
    else
    {
      // this is needed on platforms less than iOS 11 (i.e. iOS 10)
      // On those platforms, iOS adds a empty header at the top of the collection view
      self.automaticallyAdjustsScrollViewInsets = false;
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == MainViewController.LaunchMoviePosterDetailView
    {
      // Clear the navigation title of this view controller so that the back button of the child
      // view does not include text.
      self.navigationItem.title = " "
      
      let destinationViewController = segue.destination as! MoviePosterDetailViewController
      
      destinationViewController.movieListResultObject = sender as! MovieListResultObject
      
      destinationViewController.posterWidth = posterWidth
      
      destinationViewController.favoriteStateChangeDelegate = self
      
      destinationViewController.orientationChangeDelegate = self
      
      NotificationCenter.default.removeObserver(self,
                                                name: NSNotification.Name.UIDeviceOrientationDidChange,
                                                object: nil)
    }
  }
  
  func onMovieResults(movieResultsResponse : DataResponse<Any>)
  {
    if(movieResultsResponse.result.isSuccess)
    {
      let resultJson : JSON = JSON(movieResultsResponse.result.value!)
      
      let movieResultArray : [MovieListResultObject] = TheMovieDatabaseUtils.movieJsonToMovieResultArray(resultJson)
      
      movieListResultObjectArray = movieResultArray
      
      moviePosterCollectionView.reloadData()
    }
    else
    {
      // TODO: handle failure
    }
  }
  
  func onActionSheetClickHelper(_ sortSetting : Int) -> Void
  {
    if(popularMoviesSettings.getSortSetting() != sortSetting)
    {
      popularMoviesSettings.setSortSetting(sortSetting)
      
      // reset the movie list array
      movieListResultObjectArray = [MovieListResultObject]()
      
      // ensure we reload the tableview to prevent the table view using the old movie list count
      moviePosterCollectionView.reloadData()
      
      // fetch movie posters
      dispatchMovieListResultRequest()
    }
  }

  /// Return a poster width given the specified max cell width.
  ///
  /// - Parameter maxCellWidth: the max width of a cell in a collection view.
  /// - Returns: width of a poster given the max cell width parameter.
  func posterWidthForCellWidth(_ maxCellWidth : Int) -> TheMovieDatabaseUtils.MoviePosterWidths
  {
    if maxCellWidth >= TheMovieDatabaseUtils.MoviePosterWidths.w185.rawValue
    {
      return TheMovieDatabaseUtils.MoviePosterWidths.w185
    }
    else if maxCellWidth >= TheMovieDatabaseUtils.MoviePosterWidths.w154.rawValue
    {
      return TheMovieDatabaseUtils.MoviePosterWidths.w154
    }
    else
    {
      return TheMovieDatabaseUtils.MoviePosterWidths.w92
    }
  }

  /// Calculate the size of a cell within the collection view of this view controller given the
  /// specified parameters. Use this function for scaling (up/down) movie posters given the
  /// parameters.
  ///
  /// - Parameters:
  ///   - screenWidth: the width of the screen.
  ///   - moviePosterWidth: the width of the movie poster that is being targeted.
  ///   - numberPostersInRow: the number of posters within one row or -1 if this function should
  /// calculate how many posters should be in a row.
  ///   - horizontalGapBetweenPosters: the horizontal gap between posters in a row.
  /// - Returns: the new size of a cell given the specified parameters.
  func computeItemSize(_ screenWidth : CGFloat,
                       _ moviePosterWidth : TheMovieDatabaseUtils.MoviePosterWidths,
                       _ numberPostersInRow : Int,
                       _ horizontalGapBetweenPosters : Int) -> CGSize
  {
    // movie posters are images in portrait mode that have an aspect ratio of 2:3
    let horizontalAspectRatio = 2
    let verticalAspectRatio = 3
    
    var calculatedNumberPostersInRow = 0
    
    if numberPostersInRow == -1
    {
      // calculate the number of posters that can fit in a row
      calculatedNumberPostersInRow = Int(screenWidth / CGFloat(moviePosterWidth.rawValue))
    }
    else
    {
      // use the client value
      calculatedNumberPostersInRow = numberPostersInRow
    }
    
    let widthPostersInRow = CGFloat(moviePosterWidth.rawValue) * CGFloat(calculatedNumberPostersInRow)
    
    let numberHorizontalGapsInOneRow = CGFloat(calculatedNumberPostersInRow - 1)
    
    let calculatedHorizontalGaps = CGFloat(horizontalGapBetweenPosters) * numberHorizontalGapsInOneRow
    
    // check if we need to scale first
    let whatIsLeftover = screenWidth - widthPostersInRow - calculatedHorizontalGaps
    
    // split the difference between the posters in a row
    let scaleValue = whatIsLeftover / CGFloat(calculatedNumberPostersInRow)
    
    // shrink or widen the width of a poster
    let finalWidth = CGFloat(moviePosterWidth.rawValue) + scaleValue
    
    // scale the height of a poster by the aspect ratio
    let finalHeight = (finalWidth / CGFloat(horizontalAspectRatio)) * CGFloat(verticalAspectRatio)
    
    return CGSize(width: finalWidth, height: finalHeight)
  }
  
  func computeItemSize(_ screenWidth : CGFloat,
                       _ moviePosterWidth : TheMovieDatabaseUtils.MoviePosterWidths,
                       _ horizontalGapBetweenPosters : Int) -> CGSize
  {
    return computeItemSize(screenWidth, moviePosterWidth, -1, horizontalGapBetweenPosters)
  }

  /// Triggered when a user rotates the device. This function in turn calculates the size of a cell
  /// within the collection view given the orientation.
  @objc
  func onRotation() -> Void
  {
    // handle rotation if we have been rotated for the first time or if the current rotation is
    // different from the last rotation
    if actualOrientation == nil ||
      (actualOrientation != nil && actualOrientation != UIDevice.current.orientation)
    {
      actualOrientation = UIDevice.current.orientation

      let screenRect = UIScreen.main.bounds
      var landscapeScreenWidth = CGFloat(0)
      var portraitScreenWidth = CGFloat(0)
    
      let isLandscape = UIDevice.current.orientation.isLandscape
      let isPortrait = UIDevice.current.orientation == .portrait
      let isPortraitUpsideDown = UIDevice.current.orientation == .portraitUpsideDown
    
      if isLandscape
      {
        // We are in landscape mode
      
        // when in landscape mode, the "portrait width" is the "landscape height"
        landscapeScreenWidth = screenRect.size.width
        portraitScreenWidth = screenRect.size.height
      
        onOrientationChange(.landscapeLeft)
      }
      else if isPortrait
      {
        // We are in portrait mode
        portraitScreenWidth = screenRect.size.width
        landscapeScreenWidth = screenRect.size.height
      
        onOrientationChange(.portrait)
      }
      else if isPortraitUpsideDown
      {
        if lastOrientation == .landscapeLeft
        {
          landscapeScreenWidth = screenRect.size.width
          portraitScreenWidth = screenRect.size.height
        }
        else
        {
          portraitScreenWidth = screenRect.size.width
          landscapeScreenWidth = screenRect.size.height
        }
      }
      else
      {
        // we are in flat (face dowm/up) or unknown mode we will use the last orientation
        if lastOrientation == .landscapeLeft
        {
          landscapeScreenWidth = screenRect.size.width
          portraitScreenWidth = screenRect.size.height
        }
        else
        {
          // portrait
          portraitScreenWidth = screenRect.size.width
          landscapeScreenWidth = screenRect.size.height
        }
      }
    
      // we would like exactly 2 movie posters to be displayed in each row (portrait mode)
      let numberPostersInRow = 2
      
      let horizontalGapBetweenPosters = 12
      
      // calculate the max width of a cell in this row given the number of posters we want in the
      // row
      let maxCellWidth = portraitScreenWidth / CGFloat(numberPostersInRow)
      
      posterWidth = posterWidthForCellWidth(Int(maxCellWidth))
      
      if lastOrientation == .landscapeLeft
      {
        itemSize = computeItemSize(landscapeScreenWidth,
                                   posterWidth,
                                   horizontalGapBetweenPosters)
      }
      else
      {
        // scale the cell in portrait mode accordingly
        itemSize = computeItemSize(portraitScreenWidth,
                                   posterWidth,
                                   numberPostersInRow,
                                   horizontalGapBetweenPosters)
      }
    
      if !dispatchedTriggered
      {
        dispatchedTriggered = true
        
        // we do not clear the orientation flag here because at this point we have not given the
        // collection view any data so "sizeForItemAt" would never have been triggered.
        
        if isConnected
        {
          // ensure we are connected before attempting to fetch remote data
          dispatchMovieListResultRequest()
        }
      }
      else
      {
        orientationHandled = false

        // force a layout update (must call invalidateLayout after prepare)
        moviePosterCollectionView.collectionViewLayout.prepare()
        moviePosterCollectionView.collectionViewLayout.invalidateLayout()
      }
    }
  }

  func dispatchMovieListResultRequest() -> Void
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if !(setting == PopularMoviesSettings.FAVORITES)
    {
      if isConnected
      {
        if setting == PopularMoviesSettings.MOST_POPULAR
        {
          fetchMostPopular()
        }
        else
        {
          fetchTopRated()
        }
      }
    }
    else
    {
      fetchFavorites()
    }
  }
  
  func fetchMostPopular() -> Void
  {
    let theMovieDatabaseApiKey = PopularMoviesConstants.getTheMovieDatabaseApiKey()
    let page : Int = 1
    
    if let myUri = TheMovieDatabaseUtils.getPopularMoviesUri(theMovieDatabaseApiKey, page)
    {
      TheMovieDatabaseUtils.queryTheMovieDatabase(myUri, onMovieResults)
    }
  }
  
  func fetchTopRated() -> Void
  {
    let theMovieDatabaseApiKey = PopularMoviesConstants.getTheMovieDatabaseApiKey()
    let page : Int = 1
    
    if let myUri = TheMovieDatabaseUtils.getTopRatedMoviesUri(theMovieDatabaseApiKey, page)
    {
      TheMovieDatabaseUtils.queryTheMovieDatabase(myUri, onMovieResults)
    }
  }
  
  func fetchFavorites() -> Void
  {
    DbUtils.queryFavoriteDb(context, onQueryDb)
  }
  
  @IBAction func onSortNavItemClick(_ sender: Any)
  {
    // pass nil to the title and message in order to hide the title/message frame
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Most popular", style: .default, handler:
    { (action) in
      
      // Popular Movies Clicked
      self.onActionSheetClickHelper(PopularMoviesSettings.MOST_POPULAR)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Top rated", style: .default, handler:
    { (action) in
      
      // Top Movies Clicked
      self.onActionSheetClickHelper(PopularMoviesSettings.TOP_RATED)
        
    }))
    
    alert.addAction(UIAlertAction(title: "Favorites", style: .default, handler:
    { (action) in
      
      // Favorite Movies Clicked
      self.onActionSheetClickHelper(PopularMoviesSettings.FAVORITES)
        
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:
    { (action) in
      
      // Cancel Clicked, Do nothing
        
    }))
    
    // show the action sheet
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func onInfoNavItemClick(_ sender: Any)
  {
    let alert = self.storyboard?.instantiateViewController(withIdentifier: "MySBId") as! AppInfoViewController
    
    alert.providesPresentationContextTransitionStyle = true
    alert.definesPresentationContext = true
    alert.modalPresentationStyle = .overCurrentContext
    alert.modalTransitionStyle = .crossDissolve
    
    self.present(alert, animated: true)
    {
      alert.view.superview?.isUserInteractionEnabled = true
      
      // add an action to dismiss the app info alert when the user taps inside or outside of the app
      // info alert.
      alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                        action: #selector(self.alertControllerBackgroundTapped)))
    }
  }
  /// Triggered when the user taps inside or outside of the app info alert. This implementation
  /// dismisses the app info alert.
  @objc
  func alertControllerBackgroundTapped()
  {
    self.dismiss(animated: true, completion: nil)
  }
  
  /// Completion handler that is called in response to a query for the movie favorites within the
  /// database.
  ///
  /// - Parameters:
  ///   - movieFavoriteArray: an array of movie favorites from the database or an empty array if
  /// there are no favorites in the database.
  ///   - error: an Error object indicating issues fetching the favorites from the database or nil
  /// if there are no issues fetching favorites from the database.
  func onQueryDb(_ movieFavoriteArray : [MovieFavorite], _ error : Error?) -> Void
  {
    if let error = error
    {
      print("Error fetching favorite data from context \(error)")
    }
    else
    {
      // no errors
      
      if movieFavoriteArray.count > 0
      {
        // there are favorites in the database
        
        self.movieListResultObjectArray = favoritesToMovieResults(movieFavoriteArray)
        
        self.moviePosterCollectionView.reloadData()
      }
      else
      {
        // there are no favorites
        
        self.movieListResultObjectArray = []
        
        self.moviePosterCollectionView.reloadData()
      }
    }
  }
  
  /// Completion handler that is called in response to querying the favorite database for image data
  /// for a client specified movie poster.
  ///
  /// - Parameters:
  ///   - imageView: the image view that will hold the image data that was retrieved from the
  /// favorite database.
  ///   - imageData: the image data for the client specified movie poster or nil if the movie
  /// doesn't have an associated movie poster.
  ///   - error: an error object describing the error retrieving the image data or nil if there were
  /// no issues retrieving the image data from the favorite database.
  func onQueryDb(_ imageView : UIImageView,
                 _ imageData : Data?,
                 _ error : Error?) -> Void
  {
    if let error = error
    {
      print("Error fetching favorite data from context \(error)")
    }
    else
    {
      // no errors
      
      if let imageData = imageData
      {
        // there is image data in the database
        
        // set the image view
        imageView.image = UIImage(data: imageData)
      }
      else
      {
        // there is no image data in the database, should never happen.
        // TODO: Handle this case?
        // TODO: Maybe handle this case by creating a database error place holder image
      }
    }
  }
  
  /// Convert the array of Core Data movie favorite objects into an array of movie list result
  /// objects.
  ///
  /// - Parameter movieFavoriteArray: the array of Core Data favorite objects that will be converted
  /// to movie list result objects.
  /// - Returns: an array of movie list result objects that were converted from the specified array
  /// of Core Data favorite objects.
  func favoritesToMovieResults(_ movieFavoriteArray : [MovieFavorite]) -> [MovieListResultObject]
  {
    var movieResultArray : [MovieListResultObject] = []
    
    for movieFavorite in movieFavoriteArray
    {
      guard let moviePosterUrl = movieFavorite.movie_poster_url,
            let plotSynopsis = movieFavorite.movie_plot_synopsis,
            let releaseDate = movieFavorite.movie_release_date,
            let title = movieFavorite.movie_title,
            let userRating = movieFavorite.movie_user_rating
      else
      {
        // Should never happen
        print("Error movie favorite fields are not set")
        
        // return an empty array
        return []
      }
      
      let movieResult : MovieListResultObject = MovieListResultObject(moviePosterUrl,
                                                                      plotSynopsis,
                                                                      releaseDate,
                                                                      title,
                                                                      userRating,
                                                                      Int(movieFavorite.movie_id))
      
      movieResultArray.append(movieResult)
    }
    
    return movieResultArray
  }
  
  func onFavoriteStateChange()
  {
    favoritesChange = true
  }
  
  func onOrientationChange(_ newOrientation: UIDeviceOrientation)
  {
    lastOrientation = newOrientation
  }
  
  func onNetworkConnected()
  {
    isConnected = true
    if movieListResultObjectArray.isEmpty
    {
      dispatchMovieListResultRequest()
    }
  }
  
  func onNetworkDisconnected()
  {
    isConnected = false
  }
  
  /// Return true if this view controller should display a network error message to the user.
  ///
  /// - Returns: true if this view controller should display a network error message to the user.
  func isNetworkErrorState() -> Bool
  {
    return (!isConnected && movieListResultObjectArray.count == 0)
  }
  
  /// Return true if this view controller should display a favorite error message to the user.
  ///
  /// - Returns: true if this view controller should display a favorite error message to the user.
  func isFavoriteErrorState() -> Bool
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    return (setting == PopularMoviesSettings.FAVORITES && movieListResultObjectArray.count == 0)
  }
}

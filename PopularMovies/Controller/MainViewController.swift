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
                           FavoriteStateChangeDelegate
{
  @IBOutlet var moviePosterCollectionView: UICollectionView!
  
  // Gives us access to the itemSize property
  @IBOutlet var moviePosterCollectionViewFlowLayout: UICollectionViewFlowLayout!
  
  private var movieListResultObjectArray : [MovieListResultObject] = [MovieListResultObject]()
  
  private let appTitle : String = "Popular Movies"
  
  private var popularMoviesSettings : PopularMoviesSettings!
  
  static let LaunchMoviePosterDetailView : String = "launchMoviePosterDetailView"
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  private var favoritesChange : Bool = false
  
  private var posterWidth : TheMovieDatabaseUtils.MoviePosterWidths!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Set up the delegate and data source for the collection view
    moviePosterCollectionView.delegate = self
    moviePosterCollectionView.dataSource = self
    
    // default sort setting
    popularMoviesSettings = PopularMoviesSettings(PopularMoviesSettings.MOST_POPULAR)
    
    moviePosterCollectionView.register(MovieCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
    
    // register the no favorites error message
    moviePosterCollectionView.register(NoFavoritesCollectionViewCell.nib,
                                       forCellWithReuseIdentifier: NoFavoritesCollectionViewCell.reuseIdentifier)
    
    configureCollectionView()
    
    dispatchMovieListResultRequest()
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
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if setting == PopularMoviesSettings.FAVORITES && movieListResultObjectArray.count == 0
    {
      // we are in the favorite state but the favorite database is empty
      return 1
    }
    
    return movieListResultObjectArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if setting == PopularMoviesSettings.FAVORITES && movieListResultObjectArray.count == 0
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoFavoritesCollectionViewCell.reuseIdentifier,
                                                    for: indexPath) as! NoFavoritesCollectionViewCell
      
      return cell
    }
    else
    {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier,
                                                    for: indexPath) as! MovieCollectionViewCell
    
      let movePosterRelativePath : String = movieListResultObjectArray[indexPath.row].getPosterPath()
    
      let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(movePosterRelativePath)
      
      cell.movieCollectionImageView.sd_setImage(with: URL(string: moviePosterPath),
                                                placeholderImage : UIImage(named: "image_placeholder.png"))
      
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if !(setting == PopularMoviesSettings.FAVORITES && movieListResultObjectArray.count == 0)
    {
      let movieListResultObject : MovieListResultObject = movieListResultObjectArray[indexPath.row]
      
      performSegue(withIdentifier: MainViewController.LaunchMoviePosterDetailView,
                   sender: movieListResultObject)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if setting == PopularMoviesSettings.FAVORITES && movieListResultObjectArray.count == 0
    {
      // the no favorites error message should fill the size of the collection view
      return collectionView.frame.size
    }
    
    // use the default cell size otherwise
    return self.moviePosterCollectionViewFlowLayout.itemSize
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
  
  func dispatchMovieListResultRequest() -> Void
  {
    let setting : Int = popularMoviesSettings.getSortSetting()
    
    if !(setting == PopularMoviesSettings.FAVORITES)
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
}

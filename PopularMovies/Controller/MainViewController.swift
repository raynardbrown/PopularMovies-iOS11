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
                           UICollectionViewDataSource
{
  @IBOutlet var moviePosterCollectionView: UICollectionView!
  
  private var movieListResultObjectArray : [MovieListResultObject] = [MovieListResultObject]()
  
  private let appTitle : String = "Popular Movies"
  
  private var popularMoviesSettings : PopularMoviesSettings!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Set up the delegate and data source for the collection view
    moviePosterCollectionView.delegate = self
    moviePosterCollectionView.dataSource = self
    
    // default sort setting
    popularMoviesSettings = PopularMoviesSettings(PopularMoviesSettings.MOST_POPULAR)
    
    moviePosterCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil),
                                       forCellWithReuseIdentifier: "customMovieCollectionViewCell")
    
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
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int
  {
    return movieListResultObjectArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customMovieCollectionViewCell",
                                                  for: indexPath) as! MovieCollectionViewCell
    
    let movePosterRelativePath : String = movieListResultObjectArray[indexPath.row].getPosterPath()
    
    let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(movePosterRelativePath)
    
    cell.movieCollectionImageView.sd_setImage(with: URL(string: moviePosterPath),
                                              placeholderImage : UIImage(named: "image_placeholder.png"))
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    let movieListResultObject : MovieListResultObject = movieListResultObjectArray[indexPath.row]
    
    performSegue(withIdentifier: "launchMoviePosterDetailView", sender: movieListResultObject)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == "launchMoviePosterDetailView"
    {
      // Clear the navigation title of this view controller so that the back button of the child
      // view does not include text.
      self.navigationItem.title = " "
      
      let destinationViewController = segue.destination as! MoviePosterDetailViewController
      
      destinationViewController.movieListResultObject = sender as! MovieListResultObject
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
    // TODO: Implement
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
}

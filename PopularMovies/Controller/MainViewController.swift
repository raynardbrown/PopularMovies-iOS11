//
//  ViewController.swift
//
//  Created by Raynard Brown on 2018-07-06.
//  Copyright © 2018 Raynard Brown. All rights reserved.
//

import UIKit
import SDWebImage

class MainViewController : UIViewController,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource
{
  @IBOutlet var moviePosterCollectionView: UICollectionView!
  
  private var movieListResultObjectArray : [MovieListResultObject] = [MovieListResultObject]()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    // Set up the delegate and data source for the collection view
    moviePosterCollectionView.delegate = self
    moviePosterCollectionView.dataSource = self
    
    moviePosterCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil),
                                       forCellWithReuseIdentifier: "customMovieCollectionViewCell")
    
    // TODO: Temp code for testing
    let params : [String : String] = ["api_key" : PopularMoviesConstants.getTheMovieDatabaseApiKey(),
                                      "page" : "1"]
    // TODO: Temp code for testing
    TheMovieDatabaseUtils.queryTheMovieDatabase("https://api.themoviedb.org/3/movie/popular", params, onMovieResults)
  }

  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return movieListResultObjectArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customMovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
    
    let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(movieListResultObjectArray[indexPath.row].getPosterPath())
    
    cell.movieCollectionImageView.sd_setImage(with: URL(string: moviePosterPath))
    
    return cell
  }
  
  func onMovieResults(movieResults : [MovieListResultObject])
  {
    movieListResultObjectArray = movieResults
    
    moviePosterCollectionView.reloadData()
  }
}

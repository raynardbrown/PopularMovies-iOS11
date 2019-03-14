//
//  MoviePosterDetailViewController.swift
//
//  Created by Raynard Brown on 2019-03-10.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit
import SDWebImage

class MoviePosterDetailViewController : UIViewController
{
  var movieListResultObject : MovieListResultObject!
  
  @IBOutlet var movieTitleLabel: UILabel!
  @IBOutlet var moviePosterImage: UIImageView!
  @IBOutlet var movieReleaseDateText: UILabel!
  @IBOutlet var movieRatingText: UILabel!
  @IBOutlet var movieDescriptionText: UILabel!
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.title = "Movie Detail"
    
    movieTitleLabel.text = movieListResultObject.getOriginalTitle()
    
    let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(movieListResultObject.getPosterPath())
    
    moviePosterImage.sd_setImage(with: URL(string: moviePosterPath))
    
    movieReleaseDateText.text = movieListResultObject.getReleaseDate()
    
    movieRatingText.text = movieListResultObject.getUserRating()
    
    movieDescriptionText.text = movieListResultObject.getPlotSynopsis()
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
}

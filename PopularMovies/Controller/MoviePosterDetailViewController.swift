//
//  MoviePosterDetailViewController.swift
//
//  Created by Raynard Brown on 2019-03-10.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit
import SDWebImage

class MoviePosterDetailViewController : UIViewController,
                                        UITableViewDelegate,
                                        UITableViewDataSource
{
  var movieListResultObject : MovieListResultObject!

  @IBOutlet var mainTableView: UITableView!

  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    self.title = "Movie Detail"
    
    self.mainTableView.delegate = self
    self.mainTableView.dataSource = self
    
    mainTableView.register(UINib(nibName: "CustomMainDetailViewTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "CustomMainDetailViewTableViewCell")
    
    configureTableView()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let index : Int = indexPath.row
    
    var cell : UITableViewCell?
    
    if index == 0
    {
      let tempCell = tableView.dequeueReusableCell(withIdentifier: "CustomMainDetailViewTableViewCell",
                                                   for: indexPath) as! CustomMainDetailViewTableViewCell
      
      cell = updateMainCell(tempCell)
    }
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
  {
    let index : Int = indexPath.row
    
    if index == 0
    {
      // disable selecting the first row
      return nil
    }
    
    return indexPath
  }
  
  func configureTableView() -> Void
  {
    // ensure that the table view separator extends the length of a table cell
    mainTableView.separatorInset = .zero
    
    mainTableView.rowHeight = UITableViewAutomaticDimension
    mainTableView.estimatedRowHeight = 61
  }
  
  func updateMainCell(_ cell : CustomMainDetailViewTableViewCell) -> UITableViewCell
  {
    cell.moviePosterTitleLabel.text = movieListResultObject.getOriginalTitle()
    
    let moviePosterPath : String = TheMovieDatabaseUtils.getMoviePosterUriFromPath(movieListResultObject.getPosterPath())
    
    cell.moviePosterImage.sd_setImage(with: URL(string: moviePosterPath))
    
    cell.moviePosterReleaseDateLabel.text = movieListResultObject.getReleaseDate()
    
    cell.moviePosterUserRatingLabel.text = movieListResultObject.getUserRating()
    
    cell.moviePosterDescriptionLabel.text = movieListResultObject.getPlotSynopsis()
    
    return cell
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
}

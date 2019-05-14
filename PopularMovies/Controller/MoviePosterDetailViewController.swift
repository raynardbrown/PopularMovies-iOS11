//
//  MoviePosterDetailViewController.swift
//
//  Created by Raynard Brown on 2019-03-10.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit
import SDWebImage

/// A view controller that displays a detailed view of the poster that was clicked from the main
/// view controller.
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
    
    // register the main cell
    mainTableView.register(UINib(nibName: "CustomMainDetailViewTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "CustomMainDetailViewTableViewCell")
    
    // register generic header
    mainTableView.register(UINib(nibName: "DetailViewTableHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "DetailViewTableHeader")
    
    mainTableView.register(UINib(nibName: "EmptyDetailViewTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "EmptyDetailViewTableViewCell")
    
    configureTableView()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int
  {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
  {
    if section == 0
    {
      return 0 // the main section has no header
    }
    
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
  {
    if section == 1
    {
      let header = self.mainTableView.dequeueReusableHeaderFooterView(withIdentifier: "DetailViewTableHeader") as! DetailViewTableHeader
      
      header.headerLabel.text = "Trailers:"
      
      return header
    }
    
    if section == 2
    {
      let header = self.mainTableView.dequeueReusableHeaderFooterView(withIdentifier: "DetailViewTableHeader") as! DetailViewTableHeader
      
      header.headerLabel.text = "Reviews:"
      
      return header
    }
    
    return nil
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let section : Int = indexPath.section
    
    var cell : UITableViewCell?
    
    if section == 0
    {
      // the main section only has one row so there is no need to check the index
      
      let tempCell = tableView.dequeueReusableCell(withIdentifier: "CustomMainDetailViewTableViewCell",
                                                   for: indexPath) as! CustomMainDetailViewTableViewCell
      
      cell = updateMainCell(tempCell)
    }
    
    if section == 1
    {
      let tempCell = tableView.dequeueReusableCell(withIdentifier: "EmptyDetailViewTableViewCell",
                                                   for: indexPath) as! EmptyDetailViewTableViewCell
      
      tempCell.emptyCellLabel.text = "No Trailers Here"
      
      cell = tempCell
    }
    
    if section == 2
    {
      let tempCell = tableView.dequeueReusableCell(withIdentifier: "EmptyDetailViewTableViewCell",
                                                   for: indexPath) as! EmptyDetailViewTableViewCell
      
      tempCell.emptyCellLabel.text = "No Reviews Here"
      
      cell = tempCell
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
    let index : Int = indexPath.row
    
    if index == 0
    {
      // disable highlighting the first row when clicked
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
    mainTableView.tableFooterView = UIView()
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
    
    return cell
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }
}

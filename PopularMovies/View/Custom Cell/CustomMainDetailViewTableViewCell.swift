//
//  CustomMainDetailViewTableViewCell.swift
//
//  Created by Raynard Brown on 2019-03-25.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

class CustomMainDetailViewTableViewCell: UITableViewCell,
                                         Reusable,
                                         ReusableNib
{
  @IBOutlet var moviePosterTitleLabel: UILabel!
  @IBOutlet var moviePosterImage: UIImageView!
  @IBOutlet var moviePosterReleaseDateLabel: UILabel!
  @IBOutlet var moviePosterUserRatingLabel: UILabel!
  @IBOutlet var moviePosterDescriptionLabel: UILabel!
  @IBOutlet var moviePosterFavoriteButton: UIButton!

  override func awakeFromNib()
  {
    super.awakeFromNib()
  }

  @IBAction func onFavoriteButtonClicked(_ sender: Any)
  {
    
  }
}

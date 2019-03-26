//
//  CustomMainDetailViewTableViewCell.swift
//
//  Created by Raynard Brown on 2019-03-25.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

class CustomMainDetailViewTableViewCell: UITableViewCell
{
  @IBOutlet var moviePosterTitleLabel: UILabel!
  @IBOutlet var moviePosterImage: UIImageView!
  @IBOutlet var moviePosterReleaseDateLabel: UILabel!
  @IBOutlet var moviePosterUserRatingLabel: UILabel!
  @IBOutlet var moviePosterDescriptionLabel: UILabel!
  @IBOutlet var moviePosterDescriptionTrailerSeparator: MyUISeparator!
  @IBOutlet var moviePosterTrailersLabel: UILabel!
  override func awakeFromNib()
  {
    super.awakeFromNib()
  }
}

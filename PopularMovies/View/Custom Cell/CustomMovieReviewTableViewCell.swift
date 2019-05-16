//
//  CustomMovieReviewTableViewCell.swift
//
//  Created by Raynard Brown on 2019-05-13.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

class CustomMovieReviewTableViewCell : UITableViewCell,
                                       Reusable,
                                       ReusableNib
{
  @IBOutlet var reviewAuthor: UILabel!
  @IBOutlet var reviewText: UILabel!

  override func awakeFromNib()
  {
    super.awakeFromNib()
    // Initialization code
  }
}

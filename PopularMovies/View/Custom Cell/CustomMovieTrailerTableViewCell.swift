//
//  CustomMovieTrailerTableViewCell.swift
//
//  Created by Raynard Brown on 2019-03-21.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import UIKit

class CustomMovieTrailerTableViewCell: UITableViewCell,
                                       Reusable,
                                       ReusableNib
{
  @IBOutlet var movieTrailerTitleLabel: UILabel!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
  }
}

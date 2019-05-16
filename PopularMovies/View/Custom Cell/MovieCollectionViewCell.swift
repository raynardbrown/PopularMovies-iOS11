//
//  MovieCollectionViewCell.swift
//
//  Created by Raynard on 2018-07-15.
//  Copyright © 2018 Raynard Brown. All rights reserved.
//

import UIKit

/// Holder for a single movie poster in the collection of movie posters that are displayed in the
/// main view controller.
class MovieCollectionViewCell: UICollectionViewCell,
                               Reusable,
                               ReusableNib
{
  @IBOutlet var movieCollectionImageView: UIImageView!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    // Initialization code
  }
}

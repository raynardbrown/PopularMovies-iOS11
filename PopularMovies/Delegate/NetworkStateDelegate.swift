//
//  NetworkStateDelegate.swift
//
//  Created by Raynard Brown on 2019-06-03.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation

protocol NetworkStateDelegate
{
  func onNetworkConnected()
  
  func onNetworkDisconnected()
}

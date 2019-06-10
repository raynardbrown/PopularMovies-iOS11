//
//  NetworkStateDelegate.swift
//
//  Created by Raynard Brown on 2019-06-03.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Foundation

/// NetworkStateDelegate is a protocol that clients should implement if they are interested in
/// monitoring the network state in an application. In addition, clients must also register this
/// protocol with a NetworkStateMonitor.
protocol NetworkStateDelegate
{
  /// Called when the network is connected.
  func onNetworkConnected()
  
  /// Called when the network is disconnected.
  func onNetworkDisconnected()
}

//
//  NetworkStateMonitor.swift
//
//  Created by Raynard Brown on 2019-06-27.
//  Copyright © 2019 Raynard Brown. All rights reserved.
//

import Reachability

class NetworkStateMonitor
{
  private var networkStateDelegate : NetworkStateDelegate
  
  private var reachability : Reachability?
  
  init(_ networkStateDelegate : NetworkStateDelegate)
  {
    self.networkStateDelegate = networkStateDelegate
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(NetworkStateMonitor.networkStateChange),
                                           name: NSNotification.Name.reachabilityChanged,
                                           object: nil)
    
    self.reachability = Reachability.forInternetConnection()
    
    self.reachability!.reachableOnWWAN = false
    
    reachability!.startNotifier()
    
    // strangely this must be called otherwise there isn't an initial notification
    NotificationCenter.default.post(name: NSNotification.Name.reachabilityChanged, object: nil)
  }
  
  @objc
  func networkStateChange() -> Void
  {
    if reachability!.isReachableViaWiFi() || reachability!.isReachableViaWWAN()
    {
      // network available
      networkStateDelegate.onNetworkConnected()
    }
    else
    {
      // network unavailable
      networkStateDelegate.onNetworkDisconnected()
    }
  }
}

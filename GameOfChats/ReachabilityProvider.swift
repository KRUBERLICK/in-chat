//
//  ReachabilityProvider.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/4/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Alamofire
import RxSwift

class ReachabilityProvider {
    private let reachabilityManager = NetworkReachabilityManager(host: "www.google.com")
    var reachabilityStatus = Variable<NetworkReachabilityManager.NetworkReachabilityStatus>(.notReachable)

    static var shared: ReachabilityProvider = {
        return ReachabilityProvider()
    }()

    fileprivate init() {
        reachabilityManager?.listener = { [unowned self] status in
            self.reachabilityStatus.value = status
        }
        reachabilityManager?.startListening()
    }
}

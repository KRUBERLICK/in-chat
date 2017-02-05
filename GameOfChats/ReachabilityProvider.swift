//
//  ReachabilityProvider.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/4/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import ReachabilitySwift
import RxSwift

class ReachabilityProvider {
    private let reachabilityManager = Reachability()
    var reachabilityStatus = Variable<Bool>(false)

    static var shared: ReachabilityProvider = {
        return ReachabilityProvider()
    }()

    fileprivate init() {
        reachabilityManager?.whenReachable = { [unowned self] _ in
            self.reachabilityStatus.value = true
        }
        reachabilityManager?.whenUnreachable = { [unowned self] _ in
            self.reachabilityStatus.value = false
        }
        try? reachabilityManager?.startNotifier()
    }
}

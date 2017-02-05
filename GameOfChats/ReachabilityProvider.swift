//
//  ReachabilityProvider.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/4/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Firebase
import RxSwift

class ReachabilityProvider {
    private let connectedReference = FIRDatabase.database()
        .reference(withPath: ".info/connected")
    var firebaseReachabilityStatus = Variable<Bool>(false)

    static var shared: ReachabilityProvider = {
        return ReachabilityProvider()
    }()

    fileprivate init() {
        connectedReference.observe(.value, with: { [unowned self] snapshot in
            if let connected = snapshot.value as? Bool, connected {
                self.firebaseReachabilityStatus.value = true
            } else {
                self.firebaseReachabilityStatus.value = false
            }
        })
    }
}

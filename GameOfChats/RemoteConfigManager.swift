//
//  RemoteConfigManager.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/15/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Firebase
import RxSwift

class RemoteConfigManager {
    enum Keys: String {
        case registrationEnabled = "registration_enabled"
    }

    let remoteConfig = FIRRemoteConfig.remoteConfig()

    init() {
        remoteConfig.setDefaultsFromPlistFileName("RemoteConfigDefaults")
    }

    func update() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            self?.remoteConfig.fetch(
                withExpirationDuration: 10,
                completionHandler: { [weak self] status, error in
                    if case .success = status {
                        self?.remoteConfig.activateFetched()
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? NSError())
                    }
            })
            return Disposables.create()
        }
    }

    func getValue(for key: Keys) -> FIRRemoteConfigValue {
        return remoteConfig[key.rawValue]
    }
}

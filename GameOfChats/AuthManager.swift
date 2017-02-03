//
//  AuthManager.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/1/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Firebase
import RxSwift

class AuthManager {
    static var shared: AuthManager = {
        return AuthManager()
    }()

    fileprivate init() {}

    func registerUser(email: String,
                      password: String) -> Observable<FIRUser> {
        return Observable.create { observer in
            FIRAuth.auth()?.createUser(
                withEmail: email,
                password: password,
                completion: { user, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    guard let user = user else {
                        observer.onError(NSError())
                        return
                    }

                    observer.onNext(user)
                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func signInUser(email: String, password: String) -> Observable<FIRUser> {
        return Observable.create { observer in
            FIRAuth.auth()?.signIn(
                withEmail: email,
                password: password,
                completion: { user, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }

                    guard let user = user else {
                        observer.onError(NSError())
                        return
                    }

                    observer.onNext(user)
                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }

    func logout() -> Observable<Bool> {
        return Observable.create { observer in
            do {
                try FIRAuth.auth()?.signOut()
                observer.onNext(true)
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}

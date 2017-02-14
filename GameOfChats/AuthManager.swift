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
    let authProvider: FIRAuth

    var currentUserId: String {
        return authProvider.currentUser!.uid
    }

    var isLoggedIn: Bool {
        return authProvider.currentUser != nil
    }

    init(authProvider: FIRAuth) {
        self.authProvider = authProvider
    }

    func registerUser(email: String,
                      password: String) -> Observable<FIRUser> {
        return Observable.create { [weak self] observer in
            self?.authProvider.createUser(
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
        return Observable.create { [weak self] observer in
            self?.authProvider.signIn(
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
        return Observable.create { [weak self] observer in
            do {
                try self?.authProvider.signOut()
                observer.onNext(true)
                observer.onCompleted()
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}

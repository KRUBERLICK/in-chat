//
//  DatabaseManager.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/1/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Firebase
import RxSwift

class DatabaseManager {
    private let ref = FIRDatabase
        .database().reference(fromURL: "https://inchat-b4af9.firebaseio.com/")

    static var shared: DatabaseManager = {
        return DatabaseManager()
    }()

    private var usersNode: FIRDatabaseReference {
        return ref.child("users")
    }

    fileprivate init() {}

    func addUser(uid: String, username: String, email: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            strongSelf.usersNode.child(uid)
                .updateChildValues(
                    ["name": username,
                     "email": email],
                    withCompletionBlock: { error, ref in
                        if let error = error {
                            observer.onError(error)
                            return
                        }
                        observer.onNext(true)
                        observer.onCompleted()
                })
            return Disposables.create()
        }
    }

    func updateUser(_ user: User) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            if let localAvatarImage = user.localImage {
                let imageData = UIImagePNGRepresentation(localAvatarImage)!

                FIRStorage.storage().reference()
                    .child(user.uid + "-avatar.png")
                    .put(imageData, metadata: nil,
                         completion: { [weak self] metadata, error in
                            guard let downloadURL = metadata?.downloadURL(),
                                let strongSelf = self else {
                                    observer.onCompleted()
                                    return
                            }

                            strongSelf.usersNode.child(user.uid)
                                .updateChildValues(["name": user.name,
                                                    "email": user.email,
                                                    "avatar_url": downloadURL.absoluteString],
                                                   withCompletionBlock: { error, reference in
                                                    if let error = error {
                                                        observer.onError(error)
                                                        return
                                                    }
                                                    observer.onNext(true)
                                                    observer.onCompleted()
                                })
                    })
            } else {
                strongSelf.usersNode.child(user.uid)
                    .updateChildValues(["name": user.name,
                                        "email": user.email],
                                       withCompletionBlock: { error, ref in
                                        if let error = error {
                                            observer.onError(error)
                                            return
                                        }
                                        observer.onNext(true)
                                        observer.onCompleted()
                    })
            }
            return Disposables.create()
        }
    }

    func removeUserAvatar(uid: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            strongSelf.usersNode.child(uid).child("avatar_url")
                .removeValue(completionBlock: { error, ref in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    FIRStorage.storage().reference().child(uid + "-avatar.png")
                        .delete(completion: { error in
                            if let error = error {
                                observer.onError(error)
                                return
                            }
                            observer.onNext(true)
                            observer.onCompleted()
                    })

            })
            return Disposables.create()
        }
    }

    func getUserInfo(uid: String) -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            strongSelf.usersNode.child(uid).observeSingleEvent(of: .value, with: { snapshot in
                guard let dict = snapshot.value as? [String: AnyObject],
                    let username = dict["name"] as? String,
                    let email = dict["email"] as? String else {
                        observer.onError(NSError())
                        return
                }

                var avatarURL: URL?

                if let avatarURLString = dict["avatar_url"] as? String {
                    avatarURL = URL(string: avatarURLString)
                }

                let user = User(uid: uid, name: username, email: email, avatar_url: avatarURL)

                observer.onNext(user)
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func getUserInfoContinuously(uid: String) -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            strongSelf.usersNode.child(uid).observe(.value, with: { snapshot in
                guard let dict = snapshot.value as? [String: AnyObject],
                    let username = dict["name"] as? String,
                    let email = dict["email"] as? String else {
                        observer.onError(NSError())
                        return
                }

                var avatarURL: URL?

                if let avatarURLString = dict["avatar_url"] as? String {
                    avatarURL = URL(string: avatarURLString)
                }

                let user = User(uid: uid, name: username, email: email, avatar_url: avatarURL)

                observer.onNext(user)
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func getUsersList() -> Observable<User> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            strongSelf.usersNode.observe(.childAdded, with: { snapshot in
                guard let dict = snapshot.value as? [String: AnyObject],
                    let username = dict["name"] as? String,
                    let email = dict["email"] as? String else {
                        observer.onError(NSError())
                        return
                }

                let uid = snapshot.key
                var avatarURL: URL?

                if let avatarURLString = dict["avatar_url"] as? String {
                    avatarURL = URL(string: avatarURLString)
                }

                let user = User(uid: uid, name: username, email: email, avatar_url: avatarURL)

                observer.onNext(user)
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }
}

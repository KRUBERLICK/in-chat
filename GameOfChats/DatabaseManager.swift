import Firebase
import RxSwift

class DatabaseManager {
    private let database: FIRDatabase
    private var ref: FIRDatabaseReference {
        return database.reference()
    }

    private var usersNode: FIRDatabaseReference {
        return ref.child("users")
    }

    private var messagesNode: FIRDatabaseReference {
        return ref.child("messages")
    }

    private var userMessagesNode: FIRDatabaseReference {
        return ref.child("user_messages")
    }

    private var lastMessagesNode: FIRDatabaseReference {
        return ref.child("user_last_messages")
    }

    init(database: FIRDatabase) {
        self.database = database
    }

    func addUser(uid: String,
                 username: String,
                 email: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            self?.usersNode.child(uid).updateChildValues(
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
            if let localAvatarImage = user.localImage {
                let imageData = UIImagePNGRepresentation(localAvatarImage)!

                FIRStorage.storage().reference().child(user.uid + "-avatar.png")
                    .put(imageData,
                         metadata: nil,
                         completion: { [weak self] metadata, error in
                            guard let downloadURL = metadata?.downloadURL() else {
                                observer.onError(NSError())
                                return
                            }

                            if let error = error {
                                observer.onError(error)
                                return
                            }
                            self?.usersNode.child(user.uid).updateChildValues(
                                ["name": user.name,
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
                self?.usersNode.child(user.uid).updateChildValues(
                    ["name": user.name,
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
            self?.usersNode.child(uid).child("avatar_url").removeValue(
                completionBlock: { error, ref in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    FIRStorage.storage().reference().child(uid + "-avatar.png").delete(
                        completion: { error in
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
            self?.usersNode.child(uid).observeSingleEvent(
                of: .value,
                with: { snapshot in
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

                    let user = User(uid: uid,
                                    name: username,
                                    email: email,
                                    avatar_url: avatarURL)

                    observer.onNext(user)
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func getUserInfoContinuously(uid: String) -> Observable<User> {
        return Observable.create { [weak self] observer in
            self?.usersNode.child(uid).observe(
                .value,
                with: { snapshot in
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

                    let user = User(uid: uid,
                                    name: username,
                                    email: email,
                                    avatar_url: avatarURL)

                    observer.onNext(user)
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func getUsersList() -> Observable<User> {
        return Observable.create { [weak self] observer in
            self?.usersNode.observe(
                .childAdded,
                with: { snapshot in
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

                    let user = User(uid: uid,
                                    name: username,
                                    email: email,
                                    avatar_url: avatarURL)

                    observer.onNext(user)
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func addMessage(messageText: String,
                    recepientId: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let newMessageNode = self?.messagesNode.childByAutoId() else {
                return Disposables.create()
            }
            let timestamp = Date().timeIntervalSince1970

            newMessageNode.updateChildValues(
                ["text": messageText,
                 "fromId": FIRAuth.auth()!.currentUser!.uid,
                 "toId": recepientId,
                 "timestamp": timestamp],
                withCompletionBlock: { [weak self] error, ref in
                    if let error = error {
                        observer.onError(error)
                    }
                    self?.userMessagesNode.child(FIRAuth.auth()!.currentUser!.uid)
                        .child(recepientId).updateChildValues(
                            [newMessageNode.key: -timestamp],
                            withCompletionBlock: { [weak self] error, ref in
                                if let error = error {
                                    observer.onError(error)
                                    return
                                }
                                self?.userMessagesNode.child(recepientId)
                                    .child(FIRAuth.auth()!.currentUser!.uid)
                                    .updateChildValues(
                                        [newMessageNode.key: -timestamp],
                                        withCompletionBlock: { [weak self] error, ref in
                                            if let error = error {
                                                observer.onError(error)
                                                return
                                            }

                                            _ = self?.clearLastMessagasList()
                                                .subscribe(onNext: { [weak self] _ in
                                                    _ = self?.updateLastMessagesListForAllUsers()
                                                        .subscribe(onNext: {
                                                            observer.onNext($0)
                                                            observer.onCompleted()
                                                        }, onError: { error in
                                                            observer.onError(error)
                                                        })
                                                }, onError: { error in
                                                    observer.onError(error)
                                                })
                                    })
                        })
            })
            return Disposables.create()
        }
    }

    private func clearLastMessagasList() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            self?.lastMessagesNode.removeValue(completionBlock: { error, ref in
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

    private func updateLastMessagesListForAllUsers() -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            self?.userMessagesNode.observe(
                .childAdded,
                with: { [weak self] snapshot in
                    _ = self?.updateLastMessagesList(for: snapshot.key)
                        .subscribe(onNext: {
                            observer.onNext($0)
                            observer.onCompleted()
                        }, onError: { error in
                            observer.onError(error)
                        })
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    private func updateLastMessagesList(for uid: String) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            self?.userMessagesNode.child(uid).observe(
                .childAdded,
                with: { [weak self] snapshot in
                    self?.userMessagesNode.child(uid)
                        .child(snapshot.key).queryOrderedByValue()
                        .queryLimited(toFirst: 1).observeSingleEvent(
                            of: .value,
                            with: { [weak self] snapshot in
                                guard let dict = snapshot.value as? [String: Any],
                                    let messageId = dict.keys.first,
                                    let timestamp = dict.values.first as? TimeInterval else {
                                        return
                                }

                                self?.lastMessagesNode.child(uid)
                                    .updateChildValues(
                                        [messageId: timestamp],
                                        withCompletionBlock: { error, ref in
                                            if let error = error {
                                                observer.onError(error)
                                                return
                                            }
                                            observer.onNext(true)
                                            observer.onCompleted()
                                    })
                        }, withCancel: { error in
                            observer.onError(error)
                        })
            })
            return Disposables.create()
        }
    }

    func getLastMessagesList() -> Observable<Message> {
        return Observable.create { [weak self] observer in
            self?.lastMessagesNode.child(FIRAuth.auth()!.currentUser!.uid)
                .queryOrderedByValue().observe(
                    .childAdded,
                    with: { [weak self] snapshot in
                        _ = self?.getMessageInfo(for: snapshot.key)
                            .subscribe(onNext: { message in
                                observer.onNext(message)
                            }, onError: { error in
                                observer.onError(error)
                            })
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func getChatMessagesList(with partnerId: String) -> Observable<Message> {
        return Observable.create { [weak self] observer in
            self?.userMessagesNode.child(FIRAuth.auth()!.currentUser!.uid).child(partnerId)
                .queryOrderedByValue().observe(
                    .childAdded,
                    with: { [weak self] snapshot in
                        _ = self?.getMessageInfo(for: snapshot.key)
                            .subscribe(onNext: { message in
                                observer.onNext(message)
                            }, onError: { error in
                                observer.onError(error)
                            })
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }

    func getMessageInfo(for messageId: String) -> Observable<Message> {
        return Observable.create { [weak self] observer in
            self?.messagesNode.child(messageId).observeSingleEvent(
                of: .value,
                with: { snapshot in
                    guard let dict = snapshot.value as? [String: AnyObject],
                        let messageText = dict["text"] as? String,
                        let fromId = dict["fromId"] as? String,
                        let toId = dict["toId"] as? String,
                        let timestamp = dict["timestamp"] as? TimeInterval else {
                            observer.onError(NSError())
                            return
                    }

                    let message = Message(id: messageId,
                                          text: messageText,
                                          fromId: fromId,
                                          toId: toId,
                                          timestamp: timestamp)
                    
                    observer.onNext(message)
                    observer.onCompleted()
            }, withCancel: { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }
}

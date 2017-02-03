//
//  ProfileViewController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Firebase

class ProfileViewController: ASViewController<ASDisplayNode> {
    private var disposeBag = DisposeBag()
    fileprivate let tableNode = ASTableNode(style: .plain)
    fileprivate var user: User!

    init() {
        super.init(node: tableNode)
        tableNode.dataSource = self
        tableNode.delegate = self
        title = NSLocalizedString("profile", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_more"),
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.moreButtonTapped)
        )
        node.backgroundColor = .lightBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.view.separatorStyle = .none
        tableNode.view.allowsSelection = false
        setupUserInfoObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard (presentedViewController as? UIImagePickerController) == nil else {
            return
        }

        setupUserInfoObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard (presentedViewController as? UIImagePickerController) == nil else {
            return
        }

        view.endEditing(false)
        disposeBag = DisposeBag()
    }

    private func setupUserInfoObserver() {
        DatabaseManager.shared.getUserInfo(uid: FIRAuth.auth()!.currentUser!.uid)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.user = user
                strongSelf.tableNode.reloadSections(IndexSet(integer: 0), with: .fade)
                strongSelf.disposeBag = DisposeBag()
            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    @objc private func moreButtonTapped() {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""),
                                         style: .cancel,
                                         handler: nil)
        let logoutAction = UIAlertAction(title: NSLocalizedString("logout", comment: ""),
                                         style: .destructive,
                                         handler: { [unowned self] _ in
                                            self.logout()
        })

        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func logout() {
        guard let window = navigationController?.view.window else {
            return
        }

        _ = AuthManager.shared.logout()
            .observeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(title: NSLocalizedString("error", comment: ""),
                                     message: NSLocalizedString("unknown_error", comment: ""))
                }, onCompleted: { [weak window] in
                    guard let strongWindow = window else {
                        return
                    }

                    let loginViewController = LoginViewController()

                    UIView.performWithoutAnimation {
                        loginViewController.view.setNeedsLayout()
                        loginViewController.view.layoutIfNeeded()
                    }
                    UIView.transition(with: strongWindow,
                                      duration: 0.5,
                                      options: .transitionFlipFromRight,
                                      animations: {
                                        strongWindow.rootViewController = loginViewController
                    }, completion: nil)
            })
    }

    fileprivate func showAvatarPickMenu() {
        let alertController = UIAlertController(
            title: NSLocalizedString("change_avatar", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        let makePhotoAction = UIAlertAction(
            title: NSLocalizedString("make_photo", comment: ""),
            style: .default,
            handler: { _ in

        })
        let chooseFromGalleryAction = UIAlertAction(
            title: NSLocalizedString("choose_from_gallery", comment: ""),
            style: .default,
            handler: { [unowned self] _ in
                let imagePicker = UIImagePickerController()

                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
        })
        let removeAvatarAction = UIAlertAction(
            title: NSLocalizedString("remove_avatar", comment: ""),
            style: .destructive,
            handler: { [unowned self] _ in
                _ = DatabaseManager.shared.removeUserAvatar(uid: self.user.uid)
                    .subscribe(onError: { [weak self] error in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.showAlert(title: NSLocalizedString("error", comment: ""),
                                             message: NSLocalizedString("unknown_error", comment: ""))
                        }, onCompleted: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }

                            strongSelf.user.localImage = nil
                            strongSelf.user.avatar_url = nil
                            DispatchQueue.main.async {
                                strongSelf.tableNode.reloadSections(IndexSet(integer: 0), with: .fade)
                            }
                    })
        })
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: nil)

        alertController.addAction(makePhotoAction)
        alertController.addAction(chooseFromGalleryAction)
        alertController.addAction(removeAvatarAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ASTableDelegate, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode,
                   numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableNode(_ tableNode: ASTableNode,
                   nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        switch indexPath.row {
        case 0:
            return { [weak self] in
                guard let strongSelf = self else {
                    return ASCellNode()
                }

                var cellNode: ProfileHeaderCellNode

                if let user = strongSelf.user {
                    cellNode = ProfileHeaderCellNode(user: user)
                } else {
                    cellNode = ProfileHeaderCellNode()
                }

                cellNode.onUserUpdate = { user in
                    _ = DatabaseManager.shared.updateUser(user)
                        .subscribe(onError: { [weak self] error in
                            guard let strongSelf = self else {
                                return
                            }

                            strongSelf.showAlert(
                                title: NSLocalizedString("error", comment: ""),
                                message: NSLocalizedString("unknown_error", comment: "")
                            )
                            }, onCompleted: { [weak self] in
                                guard let strongSelf = self else {
                                    return
                                }

                                strongSelf.user = user
                        })
                }
                cellNode.onAvatarTap = { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.showAvatarPickMenu()
                }
                return cellNode
            }
        case 1:
            return { [weak self] in
                guard let strongSelf = self else {
                    return ASCellNode()
                }

                let cellNode: ProfileEmailCellNode

                if let email = strongSelf.user?.email {
                    cellNode = ProfileEmailCellNode(email: email)
                } else {
                    cellNode = ProfileEmailCellNode()
                }
                return cellNode
            }
        default:
            return {
                return ASCellNode()
            }
        }
    }

    func tableNode(_ tableNode: ASTableNode,
                   constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        switch indexPath.row {
        case 0:
            return ASSizeRangeMake(CGSize(width: tableNode.bounds.width,
                                          height: tableNode.bounds.width * 0.8))
        case 1:
            return ASSizeRangeMake(CGSize(width: tableNode.bounds.width, height: 70))
        default:
            return ASSizeRangeMake(.zero)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"]
            as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]
            as? UIImage {
            selectedImage = originalImage
        }
        user.avatar_url = nil
        user.localImage = selectedImage
        tableNode.reloadSections(IndexSet(integer: 0), with: .fade)

        _ = DatabaseManager.shared.updateUser(user)
            .subscribe(onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
        
        picker.dismiss(animated: true, completion: nil)
    }
}

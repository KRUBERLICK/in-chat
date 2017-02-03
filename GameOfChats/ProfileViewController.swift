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
    private let tableNode = ASTableNode(style: .plain)
    fileprivate var user: User!

    init() {
        super.init(node: tableNode)
        tableNode.dataSource = self
        tableNode.delegate = self
        title = NSLocalizedString("profile", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("logout", comment: ""),
            style: .plain,
            target: self,
            action: #selector(ProfileViewController.logout)
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
        setupUserInfoObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
                        })
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

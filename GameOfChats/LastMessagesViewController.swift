//
//  LastMessagesViewController.swift
//  GameOfChats
//
//  Created by Daniel Ilchishyn on 1/31/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import Firebase
import RxSwift

class LastMessagesViewController: ASViewController<ASTableNode> {
    private let navigationItemSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private let disposeBag = DisposeBag()

    init() {
        super.init(node: ASTableNode(style: .plain))
        node.backgroundColor = .lightBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "account"),
            style: .plain,
            target: self,
            action: #selector(LastMessagesViewController.openProfile)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(LastMessagesViewController.composeNewMessage)
        )
        navigationItem.titleView = navigationItemSpinner
        navigationItemSpinner.startAnimating()
        setupDatabaseObserver()
    }

    private func setupDatabaseObserver() {
        DatabaseManager.shared.getUserInfoContinuously(uid: FIRAuth.auth()!
            .currentUser!.uid)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.navigationItemSpinner.stopAnimating()
                strongSelf.navigationItem.titleView = nil
                strongSelf.navigationItem.title = user.name
                }, onError: { [weak self] error in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.showAlert(title: NSLocalizedString("error", comment: ""),
                                         message: NSLocalizedString("unknown_error", comment: ""))
            })
            .addDisposableTo(disposeBag)
    }

    @objc private func openProfile() {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }

    @objc private func composeNewMessage() {
        navigationController?.pushViewController(NewMessageViewController(), animated: true)
    }
}

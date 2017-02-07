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

extension LastMessagesViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode,
                   numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableNode(_ tableNode: ASTableNode,
                   nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let message = messages[indexPath.row]

        return {
            let node = MessageCellNode(message: message)

            node.onTap = {
                // do something...
            }
            return node
        }
    }

    func tableNode(_ tableNode: ASTableNode,
                   constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize(width: tableNode.bounds.width, height: 90))
    }
}

class LastMessagesViewController: ASViewController<ASTableNode> {
    private let navigationItemSpinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private let disposeBag = DisposeBag()
    private var messagesFeedDisposeBag = DisposeBag()
    private let tableNode = ASTableNode(style: .plain)
    fileprivate var messages = [Message]()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    init() {
        super.init(node: tableNode)
        tableNode.dataSource = self
        tableNode.delegate = self
        node.backgroundColor = .lightBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.view.separatorStyle = .none
        tableNode.view.allowsSelection = false
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
        view.addSubview(activityIndicatorView)
        activityIndicatorView.frame = CGRect(x: tableNode.frame.midX - 25,
                                             y: tableNode.frame.midY - 70,
                                             width: 50,
                                             height: 50)
        observeUserInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        fetchMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messagesFeedDisposeBag = DisposeBag()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messages = []
        tableNode.reloadData()
    }

    private func observeUserInfo() {
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

    private func fetchMessages() {
        DatabaseManager.shared.getMessagesList()
            .subscribe(onNext: { [weak self] message in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.activityIndicatorView.stopAnimating()
                strongSelf.messages.append(message)
                strongSelf.tableNode.performBatch(animated: true, updates: {
                    strongSelf.tableNode.insertRows(
                        at: [IndexPath(row: strongSelf.messages.count - 1,
                                       section: 0)],
                        with: .fade)
                }, completion: nil)
            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(title: NSLocalizedString("error", comment: ""),
                                     message: NSLocalizedString("unknown_error", comment: ""))
            })
            .addDisposableTo(messagesFeedDisposeBag)
    }

    @objc private func openProfile() {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }

    @objc private func composeNewMessage() {
        navigationController?.pushViewController(NewMessageViewController(), animated: true)
    }
}

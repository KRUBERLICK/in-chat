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

extension LastMessagesViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return messages
    }

    func listAdapter(_ listAdapter: IGListAdapter,
                     sectionControllerFor object: Any) -> IGListSectionController {
        return LastMessagesSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        let label = UILabel()

        label.text = "No messages"
        label.textAlignment = .center
        return label
    }
}

class LastMessagesViewController: ASViewController<ASCollectionNode> {
    private let navigationItemSpinner =
        UIActivityIndicatorView(activityIndicatorStyle: .white)
    private let disposeBag = DisposeBag()
    private var messagesFeedDisposeBag = DisposeBag()
    private let collectionNode = ASCollectionNode(
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    fileprivate var messages = [Message]()

    private let updater = IGListAdapterUpdater()

    private lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(
            updater: self.updater,
            viewController: self,
            workingRangeSize: 0
        )

        adapter.dataSource = self
        return adapter
    }()

    init() {
        super.init(node: collectionNode)
        node.backgroundColor = .lightBackground
        adapter.setASDKCollectionNode(collectionNode)
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
        observeUserInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messagesFeedDisposeBag = DisposeBag()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messages = []
        adapter.performUpdates(animated: false, completion: nil)
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

                    strongSelf.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("unknown_error", comment: "")
                    )
            })
            .addDisposableTo(disposeBag)
    }

    private func appendNewMessage(_ message: Message) {
        if messages.contains(where: { $0.toId == message.toId }) {
            messages = messages.map { $0.toId == message.toId ? message : $0 }
        } else {
            messages.append(message)
        }
        messages.sort { $0.timestamp > $1.timestamp }
    }

    private func fetchMessages() {
        DatabaseManager.shared.getUserMessagesList()
            .subscribe(onNext: { [weak self] message in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.appendNewMessage(message)
                strongSelf.adapter.performUpdates(animated: true, completion: nil)
            }, onError: { [weak self] error in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(messagesFeedDisposeBag)
    }

    @objc private func openProfile() {
        navigationController?.pushViewController(
            ProfileViewController(),
            animated: true
        )
    }

    @objc private func composeNewMessage() {
        navigationController?.pushViewController(
            NewMessageViewController(),
            animated: true
        )
    }
}

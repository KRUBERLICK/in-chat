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

        label.text = NSLocalizedString("no_messages", comment: "")
        label.textAlignment = .center
        label.textColor = .darkText
        return label
    }
}

class LastMessagesViewController: ASViewController<ASCollectionNode> {
    private let navigationItemSpinner =
        UIActivityIndicatorView(activityIndicatorStyle: .white)
    private let disposeBag = DisposeBag()
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
        fetchMessages()
    }

    private func observeUserInfo() {
        DatabaseManager.shared.getUserInfoContinuously(uid: FIRAuth.auth()!
            .currentUser!.uid)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                self.navigationItemSpinner.stopAnimating()
                self.navigationItem.titleView = nil
                self.navigationItem.title = user.name
                }, onError: { [unowned self] error in
                    guard let topVC = self.navigationController?.topViewController,
                        topVC === self else {
                            return
                    }
                    
                    self.showAlert(
                        title: NSLocalizedString("error", comment: ""),
                        message: NSLocalizedString("unknown_error", comment: "")
                    )
            })
            .addDisposableTo(disposeBag)
    }

    private func addNewMessage(_ message: Message) {
        if let index = messages.index(where: {
            ($0.fromId == message.fromId && $0.toId == message.toId)
                || ($0.fromId == message.toId && $0.toId == message.fromId)
        }) {
            messages[index] = message
        } else if !messages.isEmpty {
            var res = false

            for i in 0..<messages.count {
                if messages[i].timestamp <= message.timestamp {
                    messages.insert(message, at: i)
                    res = true
                    break
                }
            }
            if !res {
                messages.append(message)
            }
        } else {
            messages.append(message)
        }
        messages.sort(by: { $0.timestamp > $1.timestamp })
    }

    private func fetchMessages() {
        DatabaseManager.shared.getLastMessagesList()
            .subscribe(onNext: { [unowned self] message in
                self.addNewMessage(message)
                self.adapter.performUpdates(animated: true,
                                                  completion: nil)
            }, onError: { [unowned self] error in
                guard let topVC = self.navigationController?.topViewController,
                    topVC === self else {
                        return
                }

                self.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
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

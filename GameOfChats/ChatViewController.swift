//
//  ChatViewController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/6/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

extension ChatViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return messages
    }

    func listAdapter(_ listAdapter: IGListAdapter,
                     sectionControllerFor object: Any) -> IGListSectionController {
        return ChatMessagesSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        let label = UILabel()

        label.text = NSLocalizedString("no_messages", comment: "")
        label.textAlignment = .center
        label.textColor = .darkText
        label.transform = label.transform.rotated(by: CGFloat.pi)
        return label
    }
}

class ChatViewController: ViewControllerWithKeyboard {
    private let chatNode = ChatNode()
    private let companionId: String
    private let disposeBag = DisposeBag()
    private let navigationItemSpinner =
        UIActivityIndicatorView(activityIndicatorStyle: .white)
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

    fileprivate var messages = [Message]()

    init(companionId: String) {
        self.companionId = companionId
        super.init(node: chatNode)
        chatNode.onMessageSend = { [unowned self] in self.sendMessage($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addNewMessage(_ message: Message) {
        messages.append(message)
        messages.sort(by: { $0.timestamp > $1.timestamp })
    }

    private func getCompanionInfo() {
        DatabaseManager.shared.getUserInfo(uid: companionId)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                self.navigationItemSpinner.stopAnimating()
                self.navigationItem.titleView = nil
                self.navigationItem.title = user.name
            }, onError: { [unowned self] error in
                self.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    private func fetchMessages() {
        DatabaseManager.shared.getChatMessagesList(with: companionId)
            .subscribe(onNext: { [unowned self] message in
                self.addNewMessage(message)
                self.adapter.performUpdates(animated: true, completion: nil)
            }, onError: { [unowned self] error in
                self.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        chatNode.collectionNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ViewControllerWithKeyboard.hideKeyboard)
            )
        )
        adapter.setASDKCollectionNode(chatNode.collectionNode)
        navigationItem.titleView = navigationItemSpinner
        navigationItemSpinner.startAnimating()
        getCompanionInfo()
        fetchMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(false)
    }

    private func sendMessage(_ message: String) {
        guard ReachabilityProvider.shared.firebaseReachabilityStatus.value else {
            showAlert(title: NSLocalizedString("error", comment: ""),
                      message: NSLocalizedString("network_error", comment: ""))
            return
        }

        chatNode.inputContainerNode.textField.text = ""
        chatNode.inputContainerNode.sendButtonNode.isEnabled = false

        _ = DatabaseManager.shared.addMessage(messageText: message,
                                              recepientId: companionId)
            .observeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                self?.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
    }
}

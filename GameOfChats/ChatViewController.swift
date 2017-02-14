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
        return presentationManager.getChatMessagesSectionController()
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
    let chatNode = ChatNode()
    let companionId: String
    let disposeBag = DisposeBag()
    let navigationItemSpinner =
        UIActivityIndicatorView(activityIndicatorStyle: .white)
    let updater = IGListAdapterUpdater()

    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(
            updater: self.updater,
            viewController: self,
            workingRangeSize: 0
        )

        adapter.dataSource = self
        return adapter
    }()

    var messages = [Message]()
    let presentationManager: PresentationManager
    let databaseManager: DatabaseManager
    let reachabilityProvider: ReachabilityProvider

    init(companionId: String,
         presentationManager: PresentationManager,
         databaseManager: DatabaseManager,
         reachabilityProvider: ReachabilityProvider) {
        self.companionId = companionId
        self.presentationManager = presentationManager
        self.databaseManager = databaseManager
        self.reachabilityProvider = reachabilityProvider
        super.init(node: chatNode)
        chatNode.onMessageSend = { [weak self] in self?.sendMessage($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addNewMessage(_ message: Message) {
        messages.append(message)
        messages.sort(by: { $0.timestamp > $1.timestamp })
    }

    func getCompanionInfo() {
        databaseManager.getUserInfo(uid: companionId)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.navigationItemSpinner.stopAnimating()
                self?.navigationItem.titleView = nil
                self?.navigationItem.title = user.name
            }, onError: { [weak self] error in
                self?.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    func fetchMessages() {
        databaseManager.getChatMessagesList(with: companionId)
            .subscribe(onNext: { [weak self] message in
                self?.addNewMessage(message)
                self?.adapter.performUpdates(animated: true, completion: nil)
            }, onError: { [weak self] error in
                self?.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardController.parentView = view
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

    func sendMessage(_ message: String) {
        guard reachabilityProvider.firebaseReachabilityStatus.value else {
            showAlert(title: NSLocalizedString("error", comment: ""),
                      message: NSLocalizedString("network_error", comment: ""))
            return
        }

        chatNode.inputContainerNode.textField.text = ""
        chatNode.inputContainerNode.sendButtonNode.isEnabled = false

        _ = databaseManager.addMessage(messageText: message,
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

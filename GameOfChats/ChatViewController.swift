//
//  ChatViewController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/6/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class ChatViewController: ViewControllerWithKeyboard {
    private let chatNode = ChatNode()
    private let companionId: String
    private let disposeBag = DisposeBag()

    init(companionId: String) {
        self.companionId = companionId
        super.init(node: chatNode)
        chatNode.onMessageSend = { [unowned self] message in
            self.keyboardController.hideKeyboard {
                self.sendMessage(message)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getCompanionInfo() {
        DatabaseManager.shared.getUserInfo(uid: companionId)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.navigationItem.title = user.name
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
        chatNode.collectionNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ViewControllerWithKeyboard.hideKeyboard)
            )
        )
        getCompanionInfo()
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
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: ""))
            })
    }
}

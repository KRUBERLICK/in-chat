//
//  ChatViewController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/6/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class ChatViewController: ASViewController<ASDisplayNode> {
    private let chatNode = ChatNode()
    private var keyboardController: KeyboardController!

    init() {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chat"
        keyboardController = KeyboardController(view: view)
        chatNode.collectionNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ChatViewController.hideKeyboard)))
    }

    private func sendMessage(_ message: String) {
        guard ReachabilityProvider.shared.firebaseReachabilityStatus.value else {
            showAlert(title: NSLocalizedString("error", comment: ""),
                      message: NSLocalizedString("network_error", comment: ""))
            return
        }

        chatNode.inputContainerNode.textField.text = ""
        chatNode.inputContainerNode.sendButtonNode.isEnabled = false

        // TODO: Send message
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    @objc private func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}
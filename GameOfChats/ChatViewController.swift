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

    init() {
        super.init(node: chatNode)
        chatNode.onMessageSend = { [unowned self] message in
            self.sendMessage(message)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func sendMessage(_ message: String) {
        // TODO: Send message
    }
}

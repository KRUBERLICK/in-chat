//
//  ChatMessageCellNode.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/13/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import Firebase

class ChatMessageCellNode: ASCellNode {
    private let message: Message

    private let messageText: ASTextNode = {
        let node = ASTextNode()

        node.maximumNumberOfLines = 0
        return node
    }()

    private lazy var messageTextWrapper: ASDisplayNode = {
        let node = ASDisplayNode()

        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { constrainedSize in
            ASInsetLayoutSpec(
                insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                child: self.messageText
            )
        }
        node.cornerRadius = 5
        return node
    }()

    private var isOwnMessage: Bool {
        return message.fromId == FIRAuth.auth()!.currentUser!.uid
    }

    private let timeNode = ASTextNode()

    init(message: Message) {
        self.message = message
        super.init()
        automaticallyManagesSubnodes = true
        bindData()
    }

    private func bindData() {
        let ownMessageAttributes: [String: Any] = [NSForegroundColorAttributeName: UIColor.darkText,
                                                   NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        let partnerMessageAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                        NSFontAttributeName: UIFont.systemFont(ofSize: 17)]

        messageText.attributedText = NSAttributedString(
            string: message.text,
            attributes: isOwnMessage ? ownMessageAttributes : partnerMessageAttributes
        )
        messageTextWrapper.backgroundColor = isOwnMessage
            ? .separatorColor
            : .profileHeaderBackground

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none

        let timeTextAttribs: [String: Any] = [NSForegroundColorAttributeName: UIColor.separatorColor,
                                              NSFontAttributeName: UIFont.systemFont(ofSize: 12)]

        timeNode.attributedText = NSAttributedString(
            string: dateFormatter.string(from: message.timeSent),
            attributes: timeTextAttribs
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let messageAndTimeStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 5,
            justifyContent: isOwnMessage ? .end : .start,
            alignItems: .end,
            children: isOwnMessage
                ? [timeNode, messageTextWrapper]
                : [messageTextWrapper, timeNode]
        )

        messageAndTimeStack.style.flexBasis = ASDimensionMakeWithFraction(0.85)
        messageAndTimeStack.style.flexShrink = 1
        messageTextWrapper.style.flexShrink = 1
        return ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: isOwnMessage ? .end : .start,
            alignItems: .end,
            children: [messageAndTimeStack]
        )
    }

    override func didLoad() {
        super.didLoad()
        view.transform = view.transform.rotated(by: CGFloat.pi)
    }
}

//
//  ChatNode.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/6/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa

class ChatNode: ASDisplayNode {
    var onMessageSend: ((String) -> ())?

    let collectionNode: ASCollectionNode = {
        let collectionNode = ASCollectionNode(
            collectionViewLayout: UICollectionViewFlowLayout()
        )

        return collectionNode
    }()

    private lazy var inputContainerNode: InputContainerNode = {
        let node = InputContainerNode()

        node.onSendTap = { [unowned self] message in
            self.keyboardController.hideKeyboard {
                self.onMessageSend?(message)
            }
        }
        return node
    }()

    private let separatorNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = .separatorColor
        return node
    }()

    private var keyboardController: KeyboardController!

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func didLoad() {
        super.didLoad()
        keyboardController = KeyboardController(view: view)
        collectionNode.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(ChatNode.hideKeyboard))
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        inputContainerNode.style.flexBasis = ASDimensionMake(45)
        collectionNode.style.flexGrow = 1
        collectionNode.style.flexShrink = 1
        separatorNode.style.flexBasis = ASDimensionMake(1 / UIScreen.main.scale)
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .start,
            alignItems: .stretch,
            children: [collectionNode, separatorNode,  inputContainerNode]
        )
    }

    @objc private func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}

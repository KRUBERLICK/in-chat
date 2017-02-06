//
//  InputContainerNode.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/6/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa

class InputContainerNode: ASDisplayNode, UITextFieldDelegate {
    private var textFieldNode: ASDisplayNode!
    var onSendTap: ((String) -> ())?
    private let disposeBag = DisposeBag()

    private(set) lazy var textField: UITextField = {
        let textField = UITextField()

        textField.defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.darkText,
                                           NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("your_message", comment: ""),
            attributes: [NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.2),
                         NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        )
        textField.rx.text
            .subscribe(onNext: { [unowned self] text in
                self.sendButtonNode.isEnabled = !(text ?? "").isEmpty
            })
            .addDisposableTo(self.disposeBag)
        textField.returnKeyType = .send
        textField.delegate = self
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()

    private(set) lazy var sendButtonNode: ASButtonNode = {
        let buttonNode = ASButtonNode()
        let activeColor = UIColor.navigationBarBackground
        let inactiveColor = UIColor(white: 0, alpha: 0.2)

        buttonNode.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("send", comment: ""),
                attributes: [NSForegroundColorAttributeName: activeColor,
                             NSFontAttributeName: UIFont.systemFont(ofSize: 17,
                                                                    weight: UIFontWeightBold)]
        ), for: [])
        buttonNode.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("send", comment: ""),
                attributes: [NSForegroundColorAttributeName: inactiveColor,
                             NSFontAttributeName: UIFont.systemFont(ofSize: 17,
                                                                    weight: UIFontWeightBold)]
        ), for: .disabled)
        buttonNode.addTarget(self,
                             action: #selector(InputContainerNode.sendButtonTapped),
                             forControlEvents: .touchUpInside)
        return buttonNode
    }()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        textFieldNode = ASDisplayNode(viewBlock: { [unowned self] in self.textField })
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        textFieldNode.style.flexGrow = 1
        textFieldNode.style.flexShrink = 1

        let horizStack = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 10,
                                           justifyContent: .start,
                                           alignItems: .stretch,
                                           children: [textFieldNode,
                                                      sendButtonNode])
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0,
                                                            left: 10,
                                                            bottom: 0,
                                                            right: 10),
                                       child: horizStack)

        return insets
    }

    @objc private func sendButtonTapped() {
        onSendTap?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}

//
//  ProfileEmailNode.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/3/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class ProfileEmailCellNode: ASCellNode {
    private let titleNode = ASTextNode()
    private let emailNode = ASTextNode()

    init(email: String = "") {
        super.init()
        automaticallyManagesSubnodes = true

        let titleTextAttribs: [String: Any] = [NSForegroundColorAttributeName: UIColor.darkText,
                                NSFontAttributeName: UIFont.systemFont(ofSize: 25)]
        let emailTextAttribs: [String: Any] = [NSForegroundColorAttributeName: UIColor.disabledText,
                                NSFontAttributeName: UIFont.systemFont(ofSize: 15)]

        titleNode.attributedText = NSAttributedString(
            string: NSLocalizedString("email", comment: ""),
            attributes: titleTextAttribs
        )
        emailNode.attributedText = NSAttributedString(string: email,
                                                      attributes: emailTextAttribs)
        titleNode.maximumNumberOfLines = 1
        emailNode.maximumNumberOfLines = 1
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        titleNode.style.flexShrink = 1
        emailNode.style.flexShrink = 1

        let textsStack = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 0,
                                           justifyContent: .center,
                                           alignItems: .start,
                                           children: [titleNode, emailNode])
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0),
                                       child: textsStack)

        return insets
    }
}

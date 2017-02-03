//
//  UserCellNode.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class UserCellNode: ASCellNode {
    private let avatarImageNode = ASNetworkImageNode()
    private let usernameNode = ASTextNode()
    private let userEmailNode = ASTextNode()
    private let bottomLineNode = ASDisplayNode()
    var onTap: ((User) -> ())?
    private var user: User

    // FIXME: Remove default mock
    init(user: User) {
        self.user = user
        super.init()
        automaticallyManagesSubnodes = true

        let usernameTextAttribs: [String: Any] = [NSForegroundColorAttributeName: UIColor.darkText,
                                                  NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        let userEmailTextAttribs: [String: Any] = [NSForegroundColorAttributeName: UIColor.darkText,
                                                  NSFontAttributeName: UIFont.systemFont(ofSize: 15)]

        if let avatarURL = user.avatar_url {
            avatarImageNode.url = avatarURL
        } else {
            avatarImageNode.image = #imageLiteral(resourceName: "default_avatar")
        }
        usernameNode.attributedText = NSAttributedString(string: user.name,
                                                         attributes: usernameTextAttribs)
        userEmailNode.attributedText = NSAttributedString(string: user.email,
                                                          attributes: userEmailTextAttribs)
        usernameNode.maximumNumberOfLines = 1
        userEmailNode.maximumNumberOfLines = 1
        usernameNode.truncationMode = .byTruncatingTail
        userEmailNode.truncationMode = .byTruncatingTail
        bottomLineNode.backgroundColor = UIColor(hexString: "000000", alpha: 0.1)
    }

    override func didLoad() {
        super.didLoad()
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(UserCellNode.tapHandler))
        )
    }

    override func layoutSpecThatFits(
        _ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageRatio = ASRatioLayoutSpec(ratio: 1/1, child: avatarImageNode)

        usernameNode.style.flexShrink = 1
        userEmailNode.style.flexShrink = 1

        let textStack = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 0,
                                          justifyContent: .center,
                                          alignItems: .start,
                                          children: [usernameNode, userEmailNode])

        textStack.style.flexShrink = 1

        let addAvatarStack = ASStackLayoutSpec(direction: .horizontal,
                                               spacing: 10,
                                               justifyContent: .start,
                                               alignItems: .center,
                                               children: [imageRatio, textStack])
        let insets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                                       child: addAvatarStack)

        bottomLineNode.style.flexBasis = ASDimensionMake(1 / UIScreen.main.scale)

        let bottomLineStack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 0,
                                                justifyContent: .end,
                                                alignItems: .stretch,
                                                children: [bottomLineNode])
        let bottomLineOverlay = ASOverlayLayoutSpec(child: insets, overlay: bottomLineStack)

        return bottomLineOverlay
    }

    override func layout() {
        super.layout()
        avatarImageNode.cornerRadius = avatarImageNode.bounds.width / 2
        avatarImageNode.clipsToBounds = true
    }

    @objc private func tapHandler() {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                            self.view.transform = CGAffineTransform(
                                scaleX: 1, y: 1
                            )
            }, completion: { _ in
                self.onTap?(self.user)
            })
        })
    }
}

//
//  ProfileHeaderCellNode.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ProfileHeaderCellNode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard reachabilityProvider.firebaseReachabilityStatus.value else {
            return false
        }

        return true
    }
}

class ProfileHeaderCellNode: ASCellNode {
    let avatarImageNode = ASNetworkImageNode()

    lazy var nameTextField: UITextField = {
        let textField = UITextField()

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.alignment = .center
        textField.defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                           NSFontAttributeName: UIFont.systemFont(ofSize: 35),
                                           NSParagraphStyleAttributeName: paragraphStyle]
        textField.delegate = self
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .yes
        textField.returnKeyType = .done
        return textField
    }()

    var nameNode: ASDisplayNode!
    var user: User
    var onUserUpdate: ((User) -> ())?
    var onAvatarTap: (() -> ())?
    var keyboardController: KeyboardController!
    let reachabilityProvider: ReachabilityProvider

    init(user: User = User(uid: "", name: "", email: ""),
         reachabilityProvider: ReachabilityProvider) {
        self.user = user
        self.reachabilityProvider = reachabilityProvider
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .profileHeaderBackground
        nameNode = ASDisplayNode(viewBlock: { [weak self] in self?.nameTextField ?? UIView() })
        if let avatarURL = user.avatar_url {
            avatarImageNode.url = avatarURL
        } else if let localAvatar = user.localImage {
            avatarImageNode.image = localAvatar
        } else {
            avatarImageNode.image = #imageLiteral(resourceName: "default_avatar")
        }
        nameTextField.text = user.name
        avatarImageNode.addTarget(self,
                                  action: #selector(ProfileHeaderCellNode.avatarTapHandler),
                                  forControlEvents: .touchUpInside)
    }

    override func didLoad() {
        super.didLoad()
        keyboardController.parentView = view
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ProfileHeaderCellNode.hideKeyboard)
            )
        )
        _ = nameTextField.rx.text.asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let value = value,
                    !value.isEmpty,
                    let strongSelf = self else {
                        return
                }

                strongSelf.user.name = value
                strongSelf.onUserUpdate?(strongSelf.user)
            })
    }

    override func layout() {
        super.layout()
        avatarImageNode.cornerRadius = avatarImageNode.bounds.width / 2
        avatarImageNode.clipsToBounds = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        avatarImageNode.style.preferredSize = CGSize(width: 150, height: 150)
        nameNode.style.flexBasis = ASDimensionMake(50)

        let imageAndTextFieldStack = ASStackLayoutSpec(direction: .vertical,
                                                       spacing: 0,
                                                       justifyContent: .spaceAround,
                                                       alignItems: .center,
                                                       children: [avatarImageNode,
                                                                  nameNode])

        return imageAndTextFieldStack
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }

    func avatarTapHandler() {
        view.endEditing(false)
        avatarImageNode.animatePush(completion: onAvatarTap)
    }
}

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
}

class ProfileHeaderCellNode: ASCellNode {
    private let avatarImageNode = ASNetworkImageNode()
    private lazy var nameTextField: UITextField = {
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
    private var nameNode: ASDisplayNode!
    private var user: User
    var onUserUpdate: ((User) -> ())?
    private var keyboardController: KeyboardController!

    // FIXME: Remove temporary mock
    init(user: User = User.init(uid: "", name: "", email: "")) {
        self.user = user
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .profileHeaderBackground
        nameNode = ASDisplayNode(viewBlock: { [unowned self] in self.nameTextField })
        if let avatarURL = user.avatar_url {
            avatarImageNode.url = avatarURL
        } else {
            avatarImageNode.image = #imageLiteral(resourceName: "default_avatar")
        }
        nameTextField.text = user.name
    }

    override func didLoad() {
        super.didLoad()
        keyboardController = KeyboardController(view: view)
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(ProfileHeaderCellNode.hideKeyboard)
            )
        )
        _ = nameTextField.rx.text.asObservable()
            .throttle(2, scheduler: MainScheduler.instance)
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

    @objc fileprivate func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}

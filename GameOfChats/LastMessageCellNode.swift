import AsyncDisplayKit
import Firebase

class LastMessageCellNode: ASCellNode {
    private let messageTextNode: ASTextNode = {
        let node = ASTextNode()

        node.maximumNumberOfLines = 2
        node.truncationMode = .byTruncatingTail
        return node
    }()

    private let avatarImageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()

        node.backgroundColor = .separatorColor
        return node
    }()

    private let authorNameNode: ASTextNode = {
        let node = ASTextNode()

        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        return node
    }()

    private let timeNode: ASTextNode = {
        let node = ASTextNode()

        node.maximumNumberOfLines = 1
        return node
    }()

    private let disclosureIconNode: ASImageNode = {
        let node = ASImageNode()

        node.image = #imageLiteral(resourceName: "disclosure_right")
        return node
    }()

    private let separatorNode: ASDisplayNode = {
        let node = ASDisplayNode()

        node.backgroundColor = .separatorColor
        return node
    }()

    private let message: Message
    var onTap: ((String) -> ())?

    init(message: Message) {
        self.message = message
        super.init()
        automaticallyManagesSubnodes = true
        bindData()
    }

    override func didLoad() {
        super.didLoad()
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(LastMessageCellNode.tapHandler)
            )
        )
    }

    override func layout() {
        super.layout()
        avatarImageNode.cornerRadius = avatarImageNode.bounds.width / 2
        avatarImageNode.clipsToBounds = true
    }

    private func bindData() {
        _ = DatabaseManager.shared.getUserInfo(
            uid: message.toId == FIRAuth.auth()!.currentUser!.uid
                ? message.fromId
                : message.toId
            )
            .subscribe(onNext: { [weak self] user in
                guard let strongSelf = self else {
                    return
                }
                if let avatarImageURL = user.avatar_url {
                    strongSelf.avatarImageNode.url = avatarImageURL
                } else {
                    strongSelf.avatarImageNode.image = #imageLiteral(resourceName: "default_avatar")
                }
                strongSelf.authorNameNode.attributedText = NSAttributedString(
                    string: user.name,
                    attributes: [NSForegroundColorAttributeName: UIColor.darkText,
                                 NSFontAttributeName: UIFont.systemFont(
                                    ofSize: 17,
                                    weight: UIFontWeightBold)
                    ]
                )
            })

        messageTextNode.attributedText = NSAttributedString(
            string: message.fromId == FIRAuth.auth()!.currentUser!.uid
                ? NSLocalizedString("you", comment: "") + ": \(message.text)"
                : message.text,
            attributes: [NSForegroundColorAttributeName: UIColor.darkText,
                         NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        )

        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        let dateString = dateFormatter.string(from: message.timeSent)

        timeNode.attributedText = NSAttributedString(
            string: dateString,
            attributes: [NSForegroundColorAttributeName: UIColor.disabledText,
                         NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        )
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        authorNameNode.style.flexShrink = 1
        messageTextNode.style.flexShrink = 1
        avatarImageNode.style.preferredSize = CGSize(width: 60,
                                                     height: 60)

        let timeAndDisclosureIconStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 5,
            justifyContent: .center,
            alignItems: .center,
            children: [timeNode, disclosureIconNode]
        )
        let authorNameAndTimeStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .spaceBetween,
            alignItems: .center,
            children: [authorNameNode, timeAndDisclosureIconStack]
        )
        let addMessageTextStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .center,
            alignItems: .stretch,
            children: [authorNameAndTimeStack, messageTextNode]
        )

        addMessageTextStack.style.flexGrow = 1
        addMessageTextStack.style.flexShrink = 1

        let addAvatarImageStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 10,
            justifyContent: .center,
            alignItems: .center,
            children: [avatarImageNode, addMessageTextStack]
        )
        let insets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
            child: addAvatarImageStack
        )

        separatorNode.style.flexBasis = ASDimensionMake(1 / UIScreen.main.scale)

        let separatorNodeStack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 0,
            justifyContent: .end,
            alignItems: .stretch,
            children: [separatorNode]
        )
        let separatorOverlay = ASOverlayLayoutSpec(
            child: insets,
            overlay: separatorNodeStack
        )
        
        return separatorOverlay
    }
    @objc private func tapHandler() {
        animatePush { [unowned self] in
            self.onTap?(
                self.message.fromId == FIRAuth.auth()!.currentUser!.uid
                    ? self.message.toId
                    : self.message.fromId
            )
        }
    }
}

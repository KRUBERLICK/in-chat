//
//  ChatMessagesSectionController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/13/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class ChatMessagesSectionController: IGListSectionController, IGListSectionType, ASSectionController {
    var object: Message!

    override init() {
        super.init()
        inset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    func numberOfItems() -> Int {
        return 1
    }

    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let message = object!

        return {
            let node = ChatMessageCellNode(message: message)

            return node
        }
    }

    func sizeRangeForItem(at index: Int) -> ASSizeRange {
        let collectionViewWidth = collectionContext!.containerSize.width
        let minSize = CGSize(width: collectionViewWidth - 20,
                             height: 1)
        let maxSize = CGSize(width: collectionViewWidth - 20,
                             height: CGFloat.infinity)

        return ASSizeRange(min: minSize, max: maxSize)
    }

    func sizeForItem(at index: Int) -> CGSize {
        return .zero
    }

    func cellForItem(at index: Int) -> UICollectionViewCell {
        return collectionContext!.dequeueReusableCell(
            of: _ASCollectionViewCell.self,
            for: self,
            at: index
        )
    }

    func didUpdate(to object: Any) {
        self.object = object as! Message
    }

    func didSelectItem(at index: Int) {

    }
}

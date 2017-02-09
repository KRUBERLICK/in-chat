//
//  LastMessagesSectionController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/9/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class LastMessagesSectionController: IGListSectionController, IGListSectionType, ASSectionController {
    var object: Message?

    func numberOfItems() -> Int {
        return 1
    }

    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let message = object!

        return {
            let node = LastMessageCellNode(message: message)

            node.onTap = {
                // do something...
            }
            return node
        }
    }

    func sizeRangeForItem(at index: Int) -> ASSizeRange {
        return ASSizeRangeMake(
            CGSize(
                width: collectionContext!.containerSize.width,
                height: 90
            )
        )
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
        if let object = object as? Message {
            self.object = object
        }
    }

    func didSelectItem(at index: Int) {

    }
}

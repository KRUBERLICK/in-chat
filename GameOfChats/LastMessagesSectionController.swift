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
    let presentationManager: PresentationManager

    init(presentationManager: PresentationManager) {
        self.presentationManager = presentationManager
        super.init()
    }

    func numberOfItems() -> Int {
        return 1
    }

    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let message = object!

        return { [weak self] in
            guard let node = self?.presentationManager
                .getLastMessageCellNode(for: message) else {
                    return ASCellNode()
            }

            node.onTap = { [weak self] userId in
                guard let strongSelf = self,
                    let navController = self?.viewController?
                        .navigationController else {
                            return
                }

                navController.pushViewController(
                    strongSelf.presentationManager.getChatViewController(with: userId),
                    animated: true
                )
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

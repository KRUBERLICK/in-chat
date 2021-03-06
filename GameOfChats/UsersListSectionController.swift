//
//  UsersListSectionController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/10/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class UsersListSectionController: IGListSectionController, IGListSectionType, ASSectionController {
    var object: User?
    let presentationManager: PresentationManager

    init(presentationManager: PresentationManager) {
        self.presentationManager = presentationManager
        super.init()
    }

    func numberOfItems() -> Int {
        return 1
    }

    func nodeBlockForItem(at index: Int) -> ASCellNodeBlock {
        let user = object!

        return { [weak self] in
            guard let node = self?.presentationManager.getUserCellNode(for: user) else {
                return ASCellNode()
            }

            node.onTap = { [weak self] user in
                guard let strongSelf = self,
                    let navController = strongSelf.viewController?
                        .navigationController else {
                            return
                }

                navController.pushViewController(
                    strongSelf.presentationManager
                        .getChatViewController(with: user.uid),
                    animated: true
                )

                if navController.viewControllers.count > 2 {
                    navController.viewControllers.remove(
                        at: navController.viewControllers.count - 2
                    )
                }
            }
            return node
        }
    }

    func sizeRangeForItem(at index: Int) -> ASSizeRange {
        return ASSizeRangeMake(
            CGSize(
                width: collectionContext!.containerSize.width,
                height: 70
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
        self.object = object as? User
    }

    func didSelectItem(at index: Int) {

    }
}

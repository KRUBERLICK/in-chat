//
//  PresentationManager.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/14/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import DITranquillity

class PresentationManager {
    let scope: DIScope

    init(scope: DIScope) {
        self.scope = scope
    }

    // Nodes getters
    func getLastMessageCellNode(for message: Message) -> LastMessageCellNode {
        return try! scope.resolve(arg: message)
    }

    func getUserCellNode(for user: User) -> UserCellNode {
        return try! scope.resolve(arg: user)
    }

    func getChatMessageCellNode(for message: Message) -> ChatMessageCellNode {
        return try! scope.resolve(arg: message)
    }

    func getProfileHeaderCellNode(for user: User? = nil) -> ProfileHeaderCellNode {
        if let user = user {
            return try! scope.resolve(arg: user)
        } else {
            return try! scope.resolve()
        }
    }

    // ViewControllers getters
    func getInitialViewController() -> UIViewController {
        let authManager: AuthManager = try! scope.resolve()

        return authManager.isLoggedIn
            ? BaseNavigationController(rootViewController: getLastMessagesViewController())
            : getLoginViewController()
    }

    func getChatViewController(with companionId: String) -> ChatViewController {
        return try! scope.resolve(arg: companionId)
    }

    func getLastMessagesViewController() -> LastMessagesViewController {
        return try! scope.resolve()
    }

    func getProfileViewController() -> ProfileViewController {
        return try! scope.resolve()
    }

    func getNewMessageViewController() -> NewMessageViewController {
        return try! scope.resolve()
    }

    func getLoginViewController() -> LoginViewController {
        return try! scope.resolve()
    }

    // SectionControllers getters
    func getLastMessagesSectionController() -> LastMessagesSectionController {
        return try! scope.resolve()
    }

    func getUsersListSectionController() -> UsersListSectionController {
        return try! scope.resolve()
    }

    func getChatMessagesSectionController() -> ChatMessagesSectionController {
        return try! scope.resolve()
    }
}

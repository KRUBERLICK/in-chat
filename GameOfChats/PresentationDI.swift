//
//  PresentationDI.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/14/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import DITranquillity

class PresentationLayerDIModule: DIModule {
    func load(builder: DIContainerBuilder) {
        // Presentation Manager
        builder.register(PresentationManager.self)
            .initializer { PresentationManager(scope: $0) }
            .lifetime(.lazySingle)
        // Utils
        builder.register(KeyboardController.self)
            .initializer { KeyboardController() }
            .lifetime(.perDependency)
        // Nodes
        builder.register(LoginNode.self)
            .initializer { LoginNode(remoteConfigManager: *!$0) }
            .dependency { $1.keyboardController = *!$0 }
            .lifetime(.perDependency)
        builder.register(UserCellNode.self)
            .initializer { UserCellNode(user: $1) }
            .lifetime(.perDependency)
        builder.register(ProfileHeaderCellNode.self)
            .initializer { ProfileHeaderCellNode(reachabilityProvider: *!$0) }
            .initializer { ProfileHeaderCellNode(user: $1, reachabilityProvider: *!$0) }
            .dependency { $1.keyboardController = *!$0 }
            .lifetime(.perDependency)
        builder.register(LastMessageCellNode.self)
            .initializer { LastMessageCellNode(message: $1,
                                               databaseManager: *!$0,
                                               authManager: *!$0) }
            .lifetime(.perDependency)
        builder.register(InputContainerNode.self)
            .initializer { InputContainerNode() }
            .lifetime(.perDependency)
        builder.register(ChatMessageCellNode.self)
            .initializer { ChatMessageCellNode(message: $1, authManager: *!$0) }
            .lifetime(.perDependency)
        //View Controllers
        builder.register(ChatViewController.self)
            .initializer { ChatViewController(companionId: $1,
                                              presentationManager: *!$0,
                                              databaseManager: *!$0,
                                              reachabilityProvider: *!$0) }
            .dependency { $1.keyboardController = *!$0 }
            .lifetime(.perDependency)
        builder.register(ProfileViewController.self)
            .initializer { ProfileViewController(presentationManager: *!$0,
                                                 databaseManager: *!$0,
                                                 authManager: *!$0,
                                                 reachabilityProvider: *!$0) }
            .lifetime(.perDependency)
        builder.register(NewMessageViewController.self)
            .initializer { NewMessageViewController(presentationManager: *!$0, databaseManager: *!$0) }
            .lifetime(.perDependency)
        builder.register(LastMessagesViewController.self)
            .initializer { LastMessagesViewController(presentationManager: *!$0,
                                                      databaseManager: *!$0) }
            .lifetime(.perDependency)
        builder.register(LoginViewController.self)
            .initializer { LoginViewController(loginNode: *!$0,
                                               authManager: *!$0,
                                               databaseManager: *!$0,
                                               presentationManager: *!$0) }
            .lifetime(.perDependency)
        // Section Controllers
        builder.register(LastMessagesSectionController.self)
            .initializer { LastMessagesSectionController(presentationManager: *!$0) }
            .lifetime(.perDependency)
        builder.register(UsersListSectionController.self)
            .initializer { UsersListSectionController(presentationManager: *!$0) }
            .lifetime(.perDependency)
        builder.register(ChatMessagesSectionController.self)
            .initializer { ChatMessagesSectionController(presentationManager: *!$0) }
            .lifetime(.perDependency)
    }
}

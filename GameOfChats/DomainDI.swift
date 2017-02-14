//
//  DomainDI.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/14/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import DITranquillity
import Firebase

class DomainLayerDIModule: DIModule {
    func load(builder: DIContainerBuilder) {
        builder.register(FIRDatabase.self)
            .initializer { FIRDatabase.database() }
            .lifetime(.lazySingle)
        builder.register(FIRAuth.self)
            .initializer { FIRAuth.auth()! }
            .lifetime(.lazySingle)
        builder.register(ReachabilityProvider.self)
            .initializer { ReachabilityProvider(database: *!$0) }
            .lifetime(.lazySingle)
        builder.register(DatabaseManager.self)
            .initializer { DatabaseManager(database: *!$0) }
            .lifetime(.lazySingle)
        builder.register(AuthManager.self)
            .initializer { AuthManager(authProvider: *!$0) }
            .lifetime(.lazySingle)
    }
}

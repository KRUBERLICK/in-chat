//
//  User.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit

class User: IGListDiffable {
    var uid: String
    var name: String
    var email: String
    var avatar_url: URL?
    var localImage: UIImage?

    init(uid: String,
         name: String,
         email: String,
         avatar_url: URL? = nil,
         localImage: UIImage? = nil) {
        self.uid = uid
        self.name = name
        self.email = email
        self.avatar_url = avatar_url
        self.localImage = localImage
    }

    func diffIdentifier() -> NSObjectProtocol {
        return uid as NSString
    }

    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let object = object,
            let userObject = object as? User else {
                return false
        }

        return userObject.name == name && userObject.email == email
    }
}

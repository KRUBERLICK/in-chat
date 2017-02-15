//
//  User.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import ObjectMapper

class User: IGListDiffable, ImmutableMappable {
    let uid: String
    var name: String
    let email: String
    var avatar_url: URL?
    var localImage: UIImage?

    required init(map: Map) throws {
        uid = try map.value("uid")
        name = try map.value("name")
        email = try map.value("email")
        avatar_url = try? map.value("avatar_url", using: URLTransform())
    }

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

    func mapping(map: Map) {
        uid >>> map["uid"]
        name >>> map["name"]
        email >>> map["email"]
        avatar_url >>> (map["avatar_url"], URLTransform())
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

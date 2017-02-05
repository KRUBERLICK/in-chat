//
//  User.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import UIKit

struct User {
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
}

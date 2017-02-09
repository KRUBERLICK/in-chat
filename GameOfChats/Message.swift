//
//  Message.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/7/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class Message: IGListDiffable {
    var id: String
    var text: String
    var fromId: String
    var toId: String
    var timestamp: TimeInterval
    var timeSent: Date {
        return Date(timeIntervalSince1970: timestamp)
    }

    init(id: String,
         text: String,
         fromId: String,
         toId: String,
         timestamp: TimeInterval) {
        self.id = id
        self.text = text
        self.fromId = fromId
        self.toId = toId
        self.timestamp = timestamp
    }

    func diffIdentifier() -> NSObjectProtocol {
        return id as NSString
    }

    func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        guard let object = object,
            let messageObject = object as? Message else {
                return false
        }

        return messageObject.text == text
            && messageObject.fromId == fromId
            && messageObject.toId == toId
            && messageObject.timestamp == timestamp
    }
}

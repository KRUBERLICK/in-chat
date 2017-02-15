//
//  Message.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/7/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import ObjectMapper

class Message: IGListDiffable, ImmutableMappable {
    let id: String
    var text: String
    let fromId: String
    let toId: String
    var timestamp: TimeInterval
    var timeSent: Date {
        return Date(timeIntervalSince1970: timestamp)
    }

    required init(map: Map) throws {
        id = try map.value("id")
        text = try map.value("text")
        fromId = try map.value("fromId")
        toId = try map.value("toId")
        timestamp = try map.value("timestamp")
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

    func mapping(map: Map) {
        id >>> map["id"]
        text >>> map["text"]
        fromId >>> map["fromId"]
        toId >>> map["toId"]
        timestamp >>> map["timestamp"]
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

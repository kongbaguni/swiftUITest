//
//  VoteModel.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/07.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class VoteModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var targetId = ""
    @objc dynamic var regDT = Date()
    @objc dynamic var count = 0
    private var cards = List<CardModel>()
    
    func insertCartd(card: CardManager.Card) {
        let model = card.model
        cards.append(model)
        count += card.value
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["targetId"]
    }
    
    var cardsStringValue:String {
        var result = ""
        for card in cards {
            if result.isEmpty == false {
                result += ","
            }
            result += card.cardValue?.stringValue ?? ""
        }
        return result
    }
}

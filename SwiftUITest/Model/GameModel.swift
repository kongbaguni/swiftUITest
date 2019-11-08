//
//  GameModel.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/07.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class GameModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var playerId = ""
    @objc dynamic var regDT = Date()
    @objc dynamic var point = 0
    private var cards = List<CardModel>()
    
    func insertCartd(cards: [CardManager.Card]) {
        point = 0
        for c in cards {
            let model = c.model
            self.cards.append(model)
            point += c.value
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["playerId"]
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
    
    var cardsImageValues:[UIImage] {
        var result:[UIImage] = []
        for card in cards {
            if let img = card.cardValue?.image {
                result.append(img)
            }
        }
        return result
    }
}


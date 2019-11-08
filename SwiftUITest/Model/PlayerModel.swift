//
//  PlayerModel.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/06.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class PlayerModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var desc = ""
    @objc dynamic var level = 0
    @objc dynamic var totalPoint = 0
    let games = List<GameModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var player:Player {
        return .init(id:id , name: name, desc: desc, level: level, totalPoint: totalPoint, lastCards: games.last?.cardsImageValues ?? [])
    }
    
    func play() {
        func levelup() {
            level += 1
            games.removeAll()
        }
        if games.sum(ofProperty: "point") > 1000 {
            levelup()
        }
                
        let cards = CardManager.shared.popCard(cardNumber: 5)
        if let result = CardManager.shared.checkCard(tcards: cards) {
            debugPrint(result)
            switch result {
            case .royalStraightFlush, .straightFlush :
                levelup()
            default:
                break
            }
        }
        
        let game = GameModel()
        game.insertCartd(cards: cards)
        totalPoint = games.sum(ofProperty: "point") + game.point
        game.playerId = id
        games.append(game)
    }
    
    func voteClear() {
        games.removeAll()
        totalPoint = 0
        level = 0
    }
    
    var lastGamePoint:Int {
        return games.last?.point ?? 0
    }
}


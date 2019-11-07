//
//  BookModel.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/06.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class BookModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var desc = ""
    @objc dynamic var level = 0
    @objc dynamic var count = 0
    let votes = List<VoteModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var book:Book {
        return .init(id:id , name: name, desc: desc, level: level, count: count, lastCards: votes.last?.cardsStringValue ?? "")
    }
    
    func vote() {
        let a = CardManager.shared.popCard(cardNumber: 5)
        
        if votes.sum(ofProperty: "count") > 1000 {
            level += 1
            votes.removeAll()
        }
        
        let vote = VoteModel()
        for card in a {
            vote.insertCartd(card: card)
        }
        count = vote.count + votes.sum(ofProperty: "count")
        vote.targetId = id
        votes.append(vote)
    }
    
    func voteClear() {
        votes.removeAll()
        count = 0
        level = 0
    }
    
    var lastaddedCount:Int {
        return votes.last?.count ?? 0
    }
}


//
//  CardModel.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/07.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class CardModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var type:String = ""
    @objc dynamic var index:Int = 0
        
    var cardValue:CardManager.Card? {
        if let type = CardManager.CardType(rawValue: type) {
            return CardManager.Card(type: type, index: index)
        }
        return nil
    }
}

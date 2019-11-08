//
//  PlayerListView.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/08.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
struct PlayerListView : View {
    
    var players:Results<PlayerModel> {
        return try! Realm().objects(PlayerModel.self)
    }
    
    var body: some View {
        HStack {
            Text("PlayerList")
        }
    }
}

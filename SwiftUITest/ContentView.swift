//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/06.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

struct PlayerRow: View {
    let player:PlayerModel
    var body: some View {
        HStack {
            Text(player.name)
            Spacer()
            Text("\(player.money)")
        }
    }
}

struct ContentView: View {
    @State var playerName = ""
    @State var introduce = ""
    @State var money = ""
    
    var players:Results<PlayerModel> {
        return try! Realm().objects(PlayerModel.self)
    }
        
    var body: some View {
        return NavigationView {
            ScrollView {
                Text("New Player")
                HStack {
                    VStack {
                        TextField("이름", text: $playerName)
                            .padding(.horizontal, 10.0)
                        TextField("자기소개", text: $introduce)
                            .padding(.horizontal, 10.0)
                        TextField("소지금액", text: $money)
                            .padding(.horizontal, 10.0)
                            .keyboardType(.numberPad)
                    }
                    
                    Button(action: {
                        self.makePlayer()
                        let playerList = PlayerListView()
                        let vc = UIHostingController(rootView: playerList)
                    }) {
                        Text("추가")
                    }.background(Color.white)
                        .cornerRadius(10)
                        .frame(width: 80, height: 100, alignment: .center)
                        .foregroundColor(Color.black)
                        .padding(10)
                }
                Text("Players")
                if players.count > 0 {
                    PlayerRow(player: players[0])
                }
                if players.count > 1 {
                    PlayerRow(player: players[1])
                }
                if players.count > 2 {
                    PlayerRow(player: players[2])
                }
            }.onTapGesture {
                UIApplication.shared.windows.first?.endEditing(true)
            }
        }.onAppear {
        }
    }
    
    private func makePlayer() {
        if playerName.isEmpty || money.isEmpty {
            return
        }
        
        let realm = try! Realm()
        let player = PlayerModel()
        player.name = playerName
        player.introduce = introduce
        player.money = NSString(string:money).integerValue
        
        try! realm.write {
            realm.add(player)
        }

    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

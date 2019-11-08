//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/06.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

fileprivate extension Results {
    var list:[Player] {
        var result:[Player] = []
        for item in self {
            if let b = (item as? PlayerModel) {
                result.append(b.player)
            }
        }
        return result
    }
}

struct Player:Identifiable, Hashable {
    let id:String
    let name:String
    let desc:String
    let level:Int
    let totalPoint:Int
    let lastCards:[UIImage]
}

final class PlayerStore : ObservableObject {
    @Published var players:[Player] = []
    func fetch() {
        players = try! Realm().objects(PlayerModel.self)
            .sorted(byKeyPath: "name", ascending: true)
            .sorted(byKeyPath: "totalPoint", ascending: false)
            .sorted(byKeyPath: "level", ascending: false)
            .list
    }
}

struct TextRow : View {
    var player:Player
    let store:PlayerStore
    func clear() {
        let realm = try! Realm()
        if let b = realm.object(ofType: PlayerModel.self, forPrimaryKey: self.player.id) {
            realm.beginWrite()
            realm.delete(b)
            try! realm.commitWrite()
        }
    }
    
    var bgcolor:Color {
        guard let playerModel = try! Realm().object(ofType: PlayerModel.self, forPrimaryKey: self.player.id),
            let gameValue = playerModel.games.last?.gameResultValue
            else {
            return Color.black
        }
        
        switch gameValue {
        case .highcard:
            return Color(white: 0.5)
        case .onePair:
            return Color(white: 0.45)
        case .twoPairs:
            return Color(white: 0.4)
        case .threeOfaKind:
            return Color(white: 0.35)
        case .straight:
            return Color(white: 0.3)
        case .flush:
            return Color.purple
        case .fullHouse:
            return Color.orange
        case .fourOfaKind:
            return Color.green
        case .straightFlush:
            return Color.blue
        case .fiveOfaKind:
            return Color.red
        }
    }
    
    var pointMax:Int {
        let list = try! Realm().objects(PlayerModel.self)
        let max:Int? = list.max(ofProperty: "totalPoint")
        return max ?? 0
    }
    
    func getWidth(width:CGFloat,count:Int)->CGFloat {
        let min = width * 0.8
        if count <= 0 {
            return min
        }
        let value = width * CGFloat(count) / CGFloat(pointMax)
        if value <= min {
            return  min
        }
        return value
    }
    
    var body: some View {
        return GeometryReader { geo in
            HStack {
                Text(self.player.name)
                Text(self.player.desc)
                    .fontWeight(.light)
                    .font(/*@START_MENU_TOKEN@*/.caption/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.black)
                Text("\(self.player.level):\(self.player.totalPoint)")
                if self.player.lastCards.count != 0 {
                    Image(uiImage: self.player.lastCards[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 30, alignment: .center)
                    Image(uiImage: self.player.lastCards[1])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 30, alignment: .center)
                    Image(uiImage: self.player.lastCards[2])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 30, alignment: .center)
                    Image(uiImage: self.player.lastCards[3])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 30, alignment: .center)
                    Image(uiImage: self.player.lastCards[4])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 30, alignment: .center)
                }
            }
                .frame(
                    width: self.getWidth(width: geo.size.width, count: self.player.totalPoint)
                    , height: geo.size.height
                    , alignment: .center)
                .background(self.bgcolor)
                .cornerRadius(10)
                .onTapGesture {
                    let id = self.player.id
                    let realm = try! Realm()
                    if let player = realm.object(ofType: PlayerModel.self, forPrimaryKey: id) {
                        realm.beginWrite()
                        player.play()
                        try! realm.commitWrite()
                        self.store.fetch()
                    }
            }
            .onLongPressGesture {
                let id = self.player.id
                let realm = try! Realm()
                if let player = realm.object(ofType: PlayerModel.self, forPrimaryKey: id) {
                    realm.beginWrite()
                    player.games.removeAll()
                    try! realm.commitWrite()
                    self.store.fetch()
                }
                
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var store: PlayerStore = PlayerStore()
    
    @State var playerName = ""
    @State var playerDesc = ""
    @State var isAutoPlay = false
    var body: some View {
        return NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("player name", text: self.$playerName)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 30, alignment: .center)
                        TextField("player desc", text: self.$playerDesc)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 30, alignment: .center)
                    }
                    Button(action: {
                        if self.playerName.isEmpty {
                            return
                        }
                        let realm = try! Realm()
                        realm.beginWrite()
                        let newPlayer = PlayerModel()
                        newPlayer.name = self.playerName
                        newPlayer.desc = self.playerDesc
                        realm.add(newPlayer)
                        try! realm.commitWrite()
                        self.playerName.removeAll()
                        self.playerDesc.removeAll()
                        self.store.fetch()
                        UIApplication.shared.windows.first?.endEditing(true)
                        
                        
                    }) {
                        Text("저장")
                    }
                }
                HStack {
                    Button(action:{
                        self.gamePlay()
                    }) {
                        Text("play")
                    }
                    Button(action: {
                        let realm = try! Realm()
                        let list = realm.objects(PlayerModel.self)
                        if list.count > 0 {
                            realm.beginWrite()
                            for model in list {
                                model.voteClear()
                            }
                            try! realm.commitWrite()
                            self.store.fetch()
                        }
                        
                    }) {
                        Text("카운트 초기화")
                    }
                    
                    //                    Button(action: {
                    //                        let realm = try! Realm()
                    //                        let list = realm.objects(PlayerModel.self)
                    //                        if list.count == 0 {
                    //                            return
                    //                        }
                    //                        let x = Int.random(in: 0..<list.count)
                    //
                    //                        realm.beginWrite()
                    //                        list[x].vote()
                    //                        try! realm.commitWrite()
                    //                        self.store.fetch()
                    //
                    //                    }) {
                    //                        Text("vote")
                    //                    }
                    
                    Button(action: {
                        let realm = try! Realm()
                        
                        if let model = realm.objects(PlayerModel.self).last {
                            realm.beginWrite()
                            realm.delete(model)
                            try! realm.commitWrite()
                            self.store.fetch()
                        }
                        
                    }) {
                        Text("삭제")
                    }
                }
                
                List(store.players) { data in
                    TextRow(player: data, store: self.store)
                }
                
            }
        }.onAppear {
            self.store.fetch()
            self.gamePlay()
        }
    }
    
    func gamePlay() {
        let realm = try! Realm()
        let list = realm.objects(PlayerModel.self)
        if list.count == 0 && self.isAutoPlay {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.gamePlay()
            }
            return
        }
        realm.beginWrite()
        for player in list {
            player.play()
        }
        try! realm.commitWrite()
        self.store.fetch()
        if self.isAutoPlay {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.gamePlay()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

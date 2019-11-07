//
//  ContentView.swift
//  SwiftUITest
//
//  Created by Changyul Seo on 2019/11/06.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

var playerCount = 0

fileprivate extension Results {
    var list:[Book] {
        var result:[Book] = []
        for item in self {
            if let b = (item as? BookModel) {
                result.append(b.book)
            }
        }
        return result
    }
}

struct Book:Identifiable, Hashable {
    let id:String
    let name:String
    let desc:String
    let level:Int
    let count:Int
    let lastCards:String
}

final class BookStore : ObservableObject {
    @Published var books:[Book] = []
    func fetch() {
        books = try! Realm().objects(BookModel.self)
            .sorted(byKeyPath: "name", ascending: true)
            .sorted(byKeyPath: "count", ascending: false)
            .sorted(byKeyPath: "level", ascending: false)
            .list
    }
}

struct TextRow : View {
    var book:Book
    let store:BookStore
    func clear() {
        let realm = try! Realm()
        if let b = realm.object(ofType: BookModel.self, forPrimaryKey: self.book.id) {
            realm.beginWrite()
            realm.delete(b)
            try! realm.commitWrite()
        }
    }
    
    var bgcolor:Color {
        switch (self.book.count % 4) {
        case 0:
            return Color.orange
        case 1:
            return Color.red
        case 2:
            return Color.blue
        case 3:
            return Color.purple
        default:
            return Color.green
        }
    }
    
    var countMax:Int {
        let list = try! Realm().objects(BookModel.self)
        let max:Int? = list.max(ofProperty: "count")
        return max ?? 0
    }
    
    func getWidth(width:CGFloat,count:Int)->CGFloat {
        let min = width * 0.8
        if count <= 0 {
            return min
        }
        let value = width * CGFloat(count) / CGFloat(countMax)
        if value <= min {
            return  min
        }
        return value
    }
    
    var body: some View {
        return GeometryReader { geo in
            HStack {
                Text(self.book.name)
                Text(self.book.desc)
                    .fontWeight(.light)
                    .font(/*@START_MENU_TOKEN@*/.caption/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.black)
                Text("\(self.book.level):\(self.book.count)")
                Text(self.book.lastCards)
                    .foregroundColor(Color.black)
            }.rotation3DEffect(
                Angle(degrees: 5),
                axis: (
                    x: CGFloat(self.book.count % 20 - 10),
                    y: 10.0,
                    z: CGFloat(self.book.count % 20 - 10)))
                .frame(
                    width: self.getWidth(width: geo.size.width, count: self.book.count)
                    , height: geo.size.height
                    , alignment: .center)
                .background(self.bgcolor)
                .cornerRadius(10)
                .onTapGesture {
                    let id = self.book.id
                    let realm = try! Realm()
                    if let book = realm.object(ofType: BookModel.self, forPrimaryKey: id) {
                        realm.beginWrite()
                        book.vote()
                        try! realm.commitWrite()
                        self.store.fetch()
                    }
            }
            .onLongPressGesture {
                let id = self.book.id
                let realm = try! Realm()
                if let book = realm.object(ofType: BookModel.self, forPrimaryKey: id) {
                    realm.beginWrite()
                    book.votes.removeAll()
                    try! realm.commitWrite()
                    self.store.fetch()
                }
                
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var store: BookStore = BookStore()
    
    @State var bookName = ""
    @State var bookDesc = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("book name", text: self.$bookName)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 30, alignment: .center)
                        TextField("book desc", text: self.$bookDesc)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 30, alignment: .center)
                    }
                    Button(action: {
                        if self.bookName.isEmpty {
                            return
                        }
                        let realm = try! Realm()
                        realm.beginWrite()
                        let newbook = BookModel()
                        newbook.name = self.bookName
                        newbook.desc = self.bookDesc
                        realm.add(newbook)
                        try! realm.commitWrite()
                        self.bookName.removeAll()
                        self.bookDesc.removeAll()
                        self.store.fetch()
                        UIApplication.shared.windows.first?.endEditing(true)
                        
                        
                    }) {
                        Text("저장")
                    }
                }
                HStack {
                    Button(action: {
                        let realm = try! Realm()
                        let list = realm.objects(BookModel.self)
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
                    //                        let list = realm.objects(BookModel.self)
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
                        
                        if let model = realm.objects(BookModel.self).last {
                            realm.beginWrite()
                            realm.delete(model)
                            try! realm.commitWrite()
                            self.store.fetch()
                        }
                        
                    }) {
                        Text("삭제")
                    }
                }
                
                List(store.books) { data in
                    TextRow(book: data, store: self.store)
                }
                
            }
        }.onAppear {
            self.store.fetch()
            self.autoVote()
        }
    }
    
    func autoVote() {
        let realm = try! Realm()
        let list = realm.objects(BookModel.self)
        if list.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.autoVote()
            }
            return
        }
        playerCount += 1
        let x = playerCount % list.count
        
        realm.beginWrite()
        list[x].vote()
        try! realm.commitWrite()
        self.store.fetch()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.autoVote()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

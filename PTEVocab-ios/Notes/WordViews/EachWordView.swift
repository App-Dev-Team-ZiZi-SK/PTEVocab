//
//  EachWordView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 28/2/21.
//

import SwiftUI
import RealmSwift

struct EachWordView: View {
    @Environment(\.presentationMode) var mode
    @ObservedObject var wordObject : WordRealm
    @State var objectWord : String
    @State var objectComm : String
    
    var body: some View {
        HStack{
            VStack{
                HStack{
                    TextField("Type word", text: $objectWord)
                        .padding()
                    
                    Button {
                        // Create an object
                        let realm = try! Realm()
                        let editedWordObject = realm.object(ofType: WordRealm.self, forPrimaryKey: wordObject.id)!
    
                        try! realm.write {
                            print("EachWordView: Update Favor Value WordObject")
                            editedWordObject.isFavorited.toggle()
                        }
                    } label: {
                        Image(systemName: (self.wordObject.isFavorited) ?  "star.fill" :  "star")
                            .foregroundColor((self.wordObject.isFavorited) ? Color.yellow : Color.gray)
                            .padding()
                    }
                    
                    Text("\(wordObject.playedTimes)")
                        .padding()
                } // HStack
                
                Divider()
                TextField("Type Comment", text: $objectComm)
                    .padding()
                
            } // VStack
            HStack{Divider()}
            
            PlayWord(wordObjectID: self.wordObject.id, givenWord: self.objectWord)
        } // HStack
        .padding()
        .onChange(of: wordObject.isInvalidated){ value in
            if value {
                self.mode.wrappedValue.dismiss()
            }
        }
    }
}




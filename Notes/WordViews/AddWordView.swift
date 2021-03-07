//
//  AddWordView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 25/2/21.
//

import SwiftUI

struct AddWordView: View {
    @Binding var isPresented: Bool
    var noteID : String
    
    @State var word : String
    @State var comment: String
    @State var isFavor : Bool = false
    @State var favorSetColor = Color.gray
    
    var body: some View {
        Form {
            Section(header: Text("Word and Comment")) {
                TextField("Type Word", text: $word)
                TextField("Type Comment", text: $comment)
            }
            Section {
                HStack{
                    Text("Favorite: ")
                    Button {
                        self.isFavor.toggle()
                        self.favorSetColor = (self.isFavor) ? Color.yellow : Color.gray
                    } label: {
                        Image(systemName: (self.isFavor) ?  "star.fill" :  "star")
                            .foregroundColor(self.favorSetColor)
                    }
                } // HStack
            } // section
            
            Section {
                HStack{
                    Button (action: {
                        self.isPresented = false
                        
                        // Create an object
                        let newWord = WordRealm()
                        newWord.isFavorited = self.isFavor
                        newWord.word = self.word
                        newWord.comment = self.comment
                        // Add the object to the list
                        Backend.shared.addWord(parentNoteID: noteID, wordObject: newWord)
                        
                        // Empty the word
                        self.word = ""
                    }, label: {
                        Text("ADD")
                            .background((self.word.count == 0) ? Color.gray : Color.green)
                            .foregroundColor(Color.white)
                    })
                    .disabled(self.word.count == 0)
                    
                    Button(action: {
                        self.isPresented = false
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Spacer()
                }
            }
            
        }
        
    }
}


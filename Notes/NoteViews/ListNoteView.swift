//
//  ListNoteView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 18/1/21.
//

import SwiftUI

struct ListNoteView: View {
    @ObservedObject private var userData: UserData = .shared
    
    @State private var selected: String? = nil
    @State var showCreateNote = false
    @State var editMode = EditMode.inactive
    @State var viewMode = true
    
    /// Two view modes: Gallery, List
    let column = [GridItem(.flexible())]
    let columns = [GridItem(.fixed(200)),
                             GridItem(.fixed(200))]
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView {
                    LazyVGrid(columns: self.viewMode ? columns : column , alignment: .center,
                              content: {
                        ForEach(userData.noteRealms, id:\.self) { res in
                            EachNoteView(noteRealm: res)
                            
                        } // forEach
                        .onDelete { indices in
                            indices.forEach {
                                // removing from user data will refresh UI
                                let res = self.userData.noteRealms.remove(at: $0)
                                
                                // asynchronously remove from database
                                Backend.shared.deleteNote(realmToDeleteID: res.id)
                                
                            }
                        } // onDelete
                    }) // LazyGrid
                    .padding(.all, 10)
                } // ScrollView
                .sheet(isPresented: $showCreateNote) {
                    AddNoteView(isPresented: $showCreateNote, userData: userData)
                }
                // It refreshes the list of realm objects displayed on the view
                .onAppear(){
                    Backend.shared.realmUpdater()
                }
                

            } //Vstack
            .navigationBarTitle("Note", displayMode: .inline)
            .navigationBarColor(UIColor.init(hex: "#272343"))
            
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button(action: {
                        self.viewMode.toggle()
                    }, label: {
                        Image(systemName: self.viewMode ? "square.grid.2x2.fill" : "rectangle.grid.1x2.fill")
                    })
                    
                    Button(action: {
                        self.showCreateNote.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                    
                }// ToolbarItemGroup
            }// toolbar
        }
    }
}


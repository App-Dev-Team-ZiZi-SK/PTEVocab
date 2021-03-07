//
//  HomeView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 21/1/21.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var userData: UserData = .shared
    var body: some View {
        NavigationView{
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem()], alignment: .center,
                          content: {
                            ForEach(userData.noteRealms, id:\.self) { res in
                                EachNoteView(noteRealm: res)
                            } // forEach
                            
                          }) // LazyGrid
                    .padding(.all, 10)
            }// ScrollView
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarColor(UIColor.init(hex: "#272343"))
        }
        // Update email display
        .onAppear(){
            Backend.shared.realmUpdater()
        }
    }
}




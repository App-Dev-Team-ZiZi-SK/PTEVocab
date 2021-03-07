//
//  DefaultView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 18/1/21.
//

import SwiftUI


struct DefaultView: View {
    @State private var selectedTab = 0
    @State var didLoading = false
    var body: some View {
        if didLoading {
            // Three main tabs at the bottom of App
            TabView(selection: $selectedTab){
                HomeView()
                    .tabItem{
                        Image(self.selectedTab == 0 ? "home_" : "home")
                    }
                    .tag(0)
                ListNoteView()
                    .tabItem{
                        Image(self.selectedTab == 1 ? "notelist_" : "notelist")
                    }
                    .tag(1)
                
                UserView()
                    .tabItem{
                        Image(self.selectedTab == 2 ? "prfile_" : "prfile")
                    }
                    .tag(2)
            } // Tab
            .frame(width: Frame().SCREEN_WIDTH, height: Frame().SCREEN_HEIGHT - 100)
        } else {
            LoadingView(isPresented: $didLoading)
        }
    }
}

struct DefaultView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultView()
    }
}

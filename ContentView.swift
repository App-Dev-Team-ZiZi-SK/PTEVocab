//
//  ContentView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 15/1/21.
//

import SwiftUI
import AWSMobileClient
import Combine

struct ContentView: View {
    @ObservedObject private var userData: UserData = .shared
    let timer = BackupTimer()
    
    var body: some View {
        ZStack {
            if (userData.isSignedIn) {
                DefaultView()
            } else {
                LoginView()
            }
        }
        .onReceive(timer.currentTimePublisher) { newCurrentTime in
            Backend.shared.timedUpdate()
        }
        .onDisappear(){
            Backend.shared.timedUpdate()
        }
    }
}
extension ContentView{
    class BackupTimer{
        let currentTimePublisher = Timer.TimerPublisher(interval: 10.0, runLoop: .main, mode: .default)
        let cancellable: AnyCancellable?
        
        init() {
            self.cancellable = currentTimePublisher.connect() as? AnyCancellable
        }
        
        deinit {
            self.cancellable?.cancel()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

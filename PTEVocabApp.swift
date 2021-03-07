//
//  PTEVocabApp.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 15/1/21.
//

import SwiftUI

@main
struct PTEVocabApp: App {
    var body: some Scene {
        let _ = Backend.initialize()
        WindowGroup {
            ContentView()
        }
    }
}

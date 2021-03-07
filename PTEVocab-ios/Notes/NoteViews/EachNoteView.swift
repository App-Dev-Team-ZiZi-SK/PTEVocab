//
//  EachNoteView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 25/1/21.
//

import SwiftUI
import RealmSwift

struct EachNoteView: View {
    @ObservedObject var noteRealm : NoteRealm
    let frame = Frame()
    
    var body: some View {
        NavigationLink(destination: ListWordView(noteRealm: noteRealm)){
            VStack(alignment: .center, spacing: 5.0) {
                if let data = noteRealm.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(minWidth: self.frame.SCREEN_WIDTH / 3, maxWidth: self.frame.SCREEN_WIDTH * 0.8, minHeight: self.frame.SCREEN_WIDTH / 3, maxHeight: self.frame.SCREEN_WIDTH * 0.8, alignment: .center)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                        .scaledToFit()
                        .overlay(ImageOverlay(imgName: "go")
                                    .frame(width: self.frame.SCREEN_WIDTH / 18, height: self.frame.SCREEN_WIDTH / 18)
                                    .padding(.all, 10),
                                 alignment: .bottomTrailing)

                } else {        
                    // It should not be triggerred
                    // getPreSginedURL calls init incase it does not exist on the server.
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: Frame().SCREEN_WIDTH/3,
                               height: Frame().SCREEN_HEIGHT/5)
                }
                
                Text(noteRealm.noteName)
                    .bold()
                    .lineLimit(1)
                
                if (noteRealm.noteRealmDescription != "") {
                    Text(noteRealm.noteRealmDescription).lineLimit(1)
                }
            } // vstack
            .padding()
            .navigationBarColor(UIColor.init(hex: "#272343"))
        }
    }
}


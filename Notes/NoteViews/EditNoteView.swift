//
//  EditNoteView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 23/2/21.
//

import SwiftUI
import RealmSwift

struct EditNoteView: View {
    @Binding var activeSheet: ActiveSheet?
    @ObservedObject var userImage : UserImage
    @State var noteInfo : editNoteInfo
    let frame = Frame()
    
    // will be picked randomly
    @State private var showImage = false
    
    var body: some View {
        Form {
            Section(header: Text("TEXT")) {
                TextField("Note Name", text: $noteInfo.coverName)
                TextField("Note Description", text: $noteInfo.coverDetails)
            }
            
            Section(header: Text("Cover Picture")) {
                // It is a simple picture display view
                    Image(uiImage: userImage.uiImage!)
                        .resizable()
                        .frame(maxWidth: self.frame.SCREEN_WIDTH * 0.7, maxHeight: self.frame.SCREEN_WIDTH * 0.7, alignment: .center)
            }
            
            Section {
                VStack {
                    Button(action: {
                        showImage.toggle()
                    }) {
                        Text("Choose your own cover picture")
                    }
                }
                .sheet(isPresented: $showImage, content: { ImagePicker(image: $userImage.uiImage, chosen: $userImage.imageLoaded)})
            }
            
            
            Section {
                Button(action: {
                    
                    self.activeSheet = nil
                    let updateDate = Date()
                    // Store the note locally
                    let realm = try! Realm()
                    let userRealm = realm.object(ofType: NoteRealm.self, forPrimaryKey: userImage.id)!
                    try! realm.write {
                        userRealm.noteName = self.noteInfo.coverName
                        userRealm.noteRealmDescription = self.noteInfo.coverDetails
                        userRealm.isCoverModified = self.noteInfo.isChanged
                        userRealm.coverModifiedAt = updateDate

                        if userImage.imageLoaded{
                            userRealm.isImageModified = true
                            userRealm.isCoverModified = true
                            userRealm.imageModifiedAt = updateDate
                            userRealm.imageData = userImage.uiImage?.pngData()
                        }
                    }
                    
                }) {
                    Text("Edit this note")
                }
            }
        }
    }
}

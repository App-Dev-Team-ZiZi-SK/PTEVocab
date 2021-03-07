//
//  AddNoteView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 15/1/21.
//

import SwiftUI
import RealmSwift


struct AddNoteView: View {
    @Binding var isPresented: Bool
    var userData: UserData
    let frame = Frame()
    
    
    // will be picked randomly
    @ObservedObject var userImage = UserImage(imageKey: nil, id: "0", imgData: nil)
    @State private var name : String        = "New Note"
    @State private var description : String = "This is a new note"
    @State private var showImage = false

    var body: some View {
        Form {
            Section(header: Text("TEXT")) {
                TextField("Name", text: $name)
                TextField("Name", text: $description)
            }
            
            Section(header: Text("Cover Picture")) {
                // It is a simple picture display view
                    Image(uiImage: userImage.uiImage!)
                        .resizable()
                        
            }
            .frame(maxWidth: self.frame.SCREEN_WIDTH * 0.7, maxHeight: self.frame.SCREEN_WIDTH * 0.7, alignment: .center)
            
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
                    let userRealm = NoteRealm()
                    let dateString = userRealm.dateToString(Date())
                    self.isPresented = false
                    userRealm.imageData = userImage.uiImage?.pngData()
                    userRealm.wordsFileKeyCreate()

                    // if chosenImage -> upload it else only save the key
                    if userImage.imageLoaded{
                        print("User Loaded own image")
                        userRealm.coverImageKeyCreate()
                        Backend.shared.uploadImageFile(imageFileKey: userRealm.imageKey!, imageData: userRealm.imageData!, noteID: userRealm.id) {result in
                            if !result {print("AddNote: Upload Cover Pic Failed")}
                        }
                        
                    } else {
                        userRealm.imageKey = userImage.imageKey
                    }

                    
                    let noteData = NoteData(id: UUID().uuidString,
                                            note_name: self.$name.wrappedValue,
                                            note_description: self.$description.wrappedValue,
                                            note_image_key: userRealm.imageKey,
                                            note_file_key: userRealm.wordsKey,
                                            note_cover_modified_at: dateString,
                                            note_image_modified_at: dateString,
                                            note_words_modified_at: dateString,
                                            note_isDeleted: false)
                    
                    let note = Note(from: noteData)
                    userRealm.noteToRealm(note)
                    
                    // Upload the note to the server
                    Backend.shared.createNote(note: note){result in
                        if !result {print("AddNote: Upload Table Failed")}
                    }
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(userRealm)
                    }
                    UserData.shared.noteRealms.append(userRealm)
                    
                }) {
                    Text("Create this note")
                }
            }
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData.shared
        AddNoteView(isPresented: .constant(false), userData: userData)
    }
}

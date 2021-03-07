//
//  ListWordView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 28/2/21.
//
// https://stackoverflow.com/a/56842343/7651048


import SwiftUI
import RealmSwift

struct ListWordView: View {
    
    @ObservedObject var noteRealm : NoteRealm
    @State private var editMode = EditMode.inactive
    @State var activeSheet: ActiveSheet? = nil
    @State var showAddWordSheet = false
    let realm = try! Realm()
    
    var body: some View {
        VStack{
            VStack{
                HStack{
                    Button(action: {
                        self.activeSheet = .Setting
                    }, label: {
                        Image("setting")
                            .resizable()
                            .frame(width: 70, height: 30, alignment: .bottomTrailing)
                            .padding(.trailing, 30)
                    })
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        if editMode == .inactive {self.editMode = .active}
                        else {self.editMode = .inactive}
                    }, label: {
                        Image((editMode == .inactive) ? "edit2" : "confirm")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    })
                    .padding(.trailing, 30)
                    
                    Button(action: {
                        self.activeSheet = .Edit
                    }, label: {
                        Image("cover")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                    .padding(.trailing, 30)
                    
                    Button(action: {
                        self.showAddWordSheet.toggle()
                    }, label: {
                        Image("add2")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                    .padding(.trailing, 30)
                } // HStack
                .frame(width: .infinity, height: 60, alignment: .center)
                
                if showAddWordSheet{
                    AddWordView(isPresented: $showAddWordSheet, noteID: noteRealm.id, word: "", comment: "")
                        .padding(.bottom, 0)
                }
                List{
                    ForEach (noteRealm.wordObjects, id:\.id) {wordObject in
                        EachWordView(wordObject: wordObject, objectWord: wordObject.word, objectComm: wordObject.comment)
                            .border(Color.gray, width: 3)
                            .padding(.all, 10)
                            .padding([.top, .bottom], 0)
                    } // forEach
                    .onDelete(perform: deleteWord)
                    
                    .onMove(perform: moveWord)
                } // List
            } // VStack
            .environment(\.editMode, $editMode)
            
            .navigationTitle(noteRealm.noteName)
            
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    NavigationLink(destination: NoteExamSetupView(noteID: noteRealm.id)){
                        Text("Exam")
                            .foregroundColor(((noteRealm.wordObjects.count < 2) ? .white : .black))
                            .fontWeight(.medium)
                            .padding()
                            .background(Color(UIColor.init(hex: (noteRealm.wordObjects.count < 2) ? "#999999" : "#BAE8E8")))
                            .disabled(noteRealm.wordObjects.count < 2)
                    }
                }
            }
            
            .sheet(item: $activeSheet) {sheet in
                switch sheet {
                case .Edit:
                    let userImage = UserImage(imageKey: self.noteRealm.imageKey, id: self.noteRealm.id, imgData: noteRealm.imageData)
                    let noteInfo = editNoteInfo(noteRealm.noteName, noteRealm.noteRealmDescription)
                    EditNoteView(activeSheet: $activeSheet, userImage: userImage, noteInfo: noteInfo)
                    
                case .Setting:
                    PickerSettingView(activeSheet: $activeSheet)
                }
            } //.sheet
            
            .background(Color(UIColor.init(hex: "#F4F4F5")))
        } // VStack
    } // View
} // Struct

extension ListWordView {
    private func deleteWord(source: IndexSet){
        if let first = source.first {
            // Delete Local Data
            try! realm.write {
                print("deleteWord: Deleted from wordObjects")
                self.noteRealm.wordObjects.remove(at: first)
                self.noteRealm.isWordsModified = true
                self.noteRealm.wordsModifiedAt = Date()
            }

            // Mark Updates
            UserData.shared.totalWordsCount -= 1
        }
    }
    
    /// Has index error
    private func moveWord(source: IndexSet, destination: Int){
        try! realm.write {
            print("moveWord: Reorder WordRealm")
            self.noteRealm.wordObjects.move(fromOffsets: source,
                              toOffset: destination)
        }
    }
}

struct editNoteInfo {
    var coverName : String {
        willSet {
            if newValue != coverName{
                self.isChanged = true
            }
        }
    }
    var coverDetails : String {
        willSet {
            if newValue != coverName{
                self.isChanged = true
            }
        }
    }
    var isChanged : Bool = false
    
    init(_ coverName: String?, _ coverDetails: String?){
        self.coverName = (coverName) ?? "New Note"
        self.coverDetails = (coverDetails) ?? "This is a new note"
    }
    
    
}

//                            let ratio = String(format: "%d",  (word.testedNum == 0 ) ? 0 : round(Double((word.correctNum / word.testedNum) * 100)))

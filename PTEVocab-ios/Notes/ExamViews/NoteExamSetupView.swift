//
//  NoteExamSetupView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 4/3/21.
//

import SwiftUI
import Foundation
import RealmSwift

struct NoteExamSetupView: View {
    var noteID : String
    @State var questionSheet : [WordRealm] = []
    @State var answerSheet : [String] = []
    
    @State var isPlayTime = false
    @State var inExam : Bool = true // When to finish
    @State var afterResult : Bool = false
    @State var getAnswer : Bool = false
    
    @State var index = 0
    @State var givenAnswer : String = ""
    @State var readQuestion : String  = ""
    @State var noteName : String = ""
    @State var correctAnswerNum = 0
    var body: some View {
        VStack{
            if !inExam{
                ExamResultView(questions: self.questionSheet,
                               answers: self.answerSheet,
                               corrections: self.correctAnswerNum)
            } else {
                NoteExamView(typedAnswer: $givenAnswer, setAnswer: $getAnswer, isPlayTime: $isPlayTime, inExam: $inExam)
                    .onChange(of: [getAnswer, isPlayTime], perform: { stats in
                        if stats[1] {
                            self.readQuestion = questionSheet[index].word
                            didPressSpeakButton()
                        }
                        if stats[0] {
                            answerSheet.append(givenAnswer.datatypeValue.lowercased())
                            print(givenAnswer.datatypeValue.lowercased())
                            examMarkUpdater()
                            self.givenAnswer = ""
                            self.getAnswer = false
                            if index < questionSheet.count - 1 {
                                self.index += 1
                            } else {
                                self.inExam = false
                            }
                        }
                        })
                    .onAppear(){
                        let realm = try! Realm()
                        let noteRealm = realm.object(ofType: NoteRealm.self, forPrimaryKey: noteID)!
                        self.noteName = noteRealm.noteName
                        self.questionSheet = noteRealm.wordObjects.shuffled()
                    }
            }
            
        } // Vstack
        .navigationBarTitle(String(format: "Exam: \(noteName)"), displayMode: .inline)
        .navigationBarColor(UIColor.init(hex: "#272343"))
    }
}

extension NoteExamSetupView{
    
    func examMarkUpdater(){
        // 1. Compare the answer with the question
        // 2. Update the sheets
        let realm = try! Realm()
        let wordObject = realm.object(ofType: WordRealm.self, forPrimaryKey: questionSheet[index].id)!
        try! realm.write {
            wordObject.playedTimes += 1
            wordObject.testedNum += 1
            if (answerSheet[index] == wordObject.word.lowercased()){
                wordObject.correctNum += 1
                self.correctAnswerNum += 1
            }
        }
        
        
    }
    
    func didPressSpeakButton() {
        // Run the speech service
        SpeechService.shared.speak(text: self.readQuestion) {
            // Re-enable after the speech service finished
            self.isPlayTime = false
        }
    }
}

struct NoteExamSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NoteExamSetupView(noteID: "0")
    }
}

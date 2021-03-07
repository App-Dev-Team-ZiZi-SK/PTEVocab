//
//  NoteExamView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 3/3/21.
//

import SwiftUI
import Foundation

struct NoteExamView: View {
    // Exam Mode Variables
    @State var isEditing : Bool = false
    @State var isAutoMode : Bool = false
    @State var isPrepTime : Bool = false
    
    @State var isTypeTime : Bool = false
    
    
    
    // Exam Setup Variables
    @State var prepTime : CGFloat = 2.0
    @State var typingTime : CGFloat = 2.0
    @State var curExamMode = ExamModes.Idle
    @State var curExamTime : CGFloat = 2.0
    @State var progressStatus : CGFloat = 0.0
    @State var progressString = ""
    
    
    // Exam Answers
    @Binding var typedAnswer : String 
    @Binding var setAnswer : Bool
    @Binding var isPlayTime : Bool
    @Binding var inExam : Bool
    
    // Extra
    let frame = Frame()
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let autoButtonColorStop = Gradient(colors: [Color.red, Color.blue])
    private let autoButtonColorAuto = Gradient(colors: [Color(UIColor.init(hex: "#11998e")), Color(UIColor.init(hex: "#38ef7d"))])
    
    var body: some View {
        
        ZStack{
            VStack{
                // Mark: Top VStack
                VStack {
                    HStack(alignment: .center, spacing: 80) {
                        // Edit Button - self.isPrepTime
                        Button(action: {
                            withAnimation {
                                self.isEditing.toggle()
                                self.stopTimer()
                            }
                        }, label: {
                            Image("Menu")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        })
                        .disabled(isPlayTime || isTypeTime)
                        .padding(.leading, 10)
                        
                        // Play Button - available in (isAutoMode || isPrepTime)
                        Button(action: {
                            // if not in Auto and prepTime -> Back in Idle Mode
                            if !isIdle() {
                                self.stopTimer()
                                self.curExamMode = ExamModes.Idle
                            } else {
                                self.startTimer()
                                self.curExamMode = ExamModes.Prep
                            }
                            // Set the Booleans
                            self.playModeSetter(input: self.curExamMode)
                        }, label: {
                            Image((isIdle()) ? "play" : "stop")
                                .frame(width: 20, height: 20)
                                .scaledToFit()
                        })
                        .disabled(isEditing || isPlayTime || isTypeTime)
                        .padding(.leading, 30)
                        
                        // Button for autoMode
                        Button(action: {
                            self.isAutoMode.toggle()
                        }, label: {
                            Text("Auto")
                                .fontWeight(.semibold)
                                .frame(minHeight: 0, maxHeight: 20)
                                .padding()
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(
                                        gradient: (self.isAutoMode) ? self.autoButtonColorStop : self.autoButtonColorAuto,
                                        startPoint: .leading,
                                        endPoint: .trailing))
                                .cornerRadius(40)
                        })
                        .disabled(self.isEditing)
                        .padding(.trailing, 25)
                    } // HStack
                    .frame(width: .infinity, height: 20)
                    .padding(.leading, 20)
                    
                    VStack{
                        PrepBarView(progress: $progressStatus)
                            .onReceive(timer, perform: {(_) in
                                // 1. Updating Bar Sequence - if not during the play or Idle
                                if curExamMode != .Play && progressStatus < 100.0 {
                                    self.progressStatus += CGFloat(100.0 / self.curExamTime * 0.1)
                                    return
                                }
                                
                                // Cannot stop the timer during the play for update
                                // 2. When finished play but in PlayMode
                                if !isPlayTime && curExamMode == .Play {
                                    self.curExamMode = .Typing
                                    self.playModeSetter(input: self.curExamMode)
                                    return
                                }
                                
                                // 4. When (prep || typing) && progressStatus > 99.0
                                // ProgressBar is 100 or Idle
                                if progressStatus > 99.0 {
                                    // 4.1 Reset the bar
                                    self.progressStatus = 0.0
                                    if curExamMode == .Prep {
                                        // Finished prep -> Play now
                                        self.curExamMode = .Play
                                    }
                                    else if curExamMode == .Typing {
                                        self.setAnswer = true
                                        // Finished Type -> Prep Mode
                                        if isAutoMode {self.curExamMode = .Prep}
                                        else {
                                            self.curExamMode = .Idle
                                            stopTimer()
                                        }
                                        
                                        // 4.2 Submit the answer
                                        self.setAnswer = true
                                        // * If not inExam -> Stop the autoMode
                                        if !inExam {
                                            stopTimer()
                                            return
                                        }
                                    }
                                    self.playModeSetter(input: self.curExamMode)
                                }
                                
                            })
                        Text(progressString)
                            .foregroundColor((self.isEditing) ? Color(UIColor.init(hex: "#272343")) : Color.white)
                            .fontWeight(.light)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: UIScreen.main.bounds.size.width, alignment: .center)
                    .padding(.top, 30)
                    
                }
                .frame(height: frame.SCREEN_HEIGHT * 0.3)
                .clipped()
                .background(Color(UIColor.init(hex: "#272343")))
                
                // Mark: Bottom VStack
                VStack{
                    TextField("Enter your answer here.", text: $typedAnswer)
                        .font(.title3)
                        .frame(width: frame.SCREEN_WIDTH * 0.5, alignment: .top)
                    
                    Rectangle().frame(width: frame.SCREEN_WIDTH * 0.7, height: 3)
                        .padding(.horizontal, 20).foregroundColor(.black)
                    
                    
                    // Submit button - Modify the
                    Button(action: {
                        self.setAnswer = true
                        self.progressStatus = 0
                    }, label: {
                        Text("Submit")
                            .scaledToFit()
                            .padding(.all, 10)
                            .padding(.top, 20)
                    })
                    .disabled(typedAnswer == "")
                    Spacer()
                }
                .padding(.top, 30)
            }
            if isEditing {
                NoteExamSettingView(isEditing: $isEditing, prepTime: $prepTime, typingTime: $typingTime)
                    .onDisappear(){
                        self.startTimer()
                    }
            }
            
            
        }
        // Mark: Navigation
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
                                    stopTimer()
                                    self.inExam = false
                                }, label: {
                                    Image("back")
                                }))
        .onAppear(){
            self.curExamMode = .Idle
            self.playModeSetter(input: self.curExamMode)
            stopTimer()
        }
    }
}

extension NoteExamView {
    func stopTimer(){
        self.timer.upstream.connect().cancel()
    }
    func startTimer(){
        self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    }
    
    func isIdle() -> Bool {
        return !(isPlayTime || isTypeTime || isPrepTime)
    }
    
    func playModeSetter(input: NoteExamView.ExamModes){
        // There are three modes: Prep - Play - Type
        // isPrepTime, isPlaying, isTypeTime : Only one is true else false
        switch(input){
        case .Prep:
            self.isPrepTime = true
            self.isTypeTime = false
            self.isPlayTime = false
            self.curExamTime = self.prepTime
            self.progressString = String(format: "Preparation Time: %.1f seconds\nGet Ready", (self.prepTime))
        case .Typing:
            self.isPrepTime = false
            self.isTypeTime = true
            self.isPlayTime = false
            self.curExamTime = self.typingTime
            self.progressString = String(format: "Typing Time: %.1f seconds \nType Carefully", (self.typingTime))
        case .Play:
            self.isPrepTime = false
            self.isTypeTime = false
            self.isPlayTime = true
            self.curExamTime = CGFloat(0.0)
            self.progressString = String(format: "Listening Time\nListen Carefully")
        case .Idle:
            self.isPrepTime = false
            self.isTypeTime = false
            self.isPlayTime = false
            self.isAutoMode = false
            self.progressString = String(format: "Preparation Time: %.1f seconds\nTyping Time: %.1f seconds\nAnswer: Case Insensitive", self.prepTime, self.typingTime)
        }
    }
    
    enum ExamModes : Int {
        case Prep = 0
        case Typing = 1
        case Play = 2
        case Idle = 3
    }
    
}

struct NoteExamView_Previews: PreviewProvider {
    static var previews: some View {
        NoteExamView(typedAnswer: .constant(""), setAnswer: .constant(false), isPlayTime: .constant(false), inExam: .constant(false))
    }
}

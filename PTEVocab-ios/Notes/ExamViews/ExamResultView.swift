//
//  ExamResultView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 4/3/21.
//

import SwiftUI

struct ExamResultView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var questions : [WordRealm]
    @State var answers : [String]
    @State var progress : Float = 0.0
    @State var corrections : Int
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Text("TOTAL MARK")
                        .foregroundColor(Color(UIColor.init(hex: "#272343")))
                        .fontWeight(.heavy)
                    
                    Text(String(format: "\(corrections) / \(answers.count)"))
                        .foregroundColor(Color(UIColor.init(hex: "#272343")))
                        .fontWeight(.heavy)
                }
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20.0)
                        .opacity(0.3)
                        .foregroundColor(Color(UIColor.init(hex: "#BAE8E8")))
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color(UIColor.init(hex: "#272343")))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear)
                    
                    Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100.0))
                        .font(.largeTitle)
                        .bold()
                }
                .frame(width: 150.0, height: 150.0)
                .padding(40.0)
                
            }
            VStack{
                ExamSubmittedAnswerView(questions: questions, answers: answers)
            }
            .onAppear(perform: {
                if answers.count == 0 {
                    self.presentationMode.wrappedValue.dismiss()
                }
                self.progress = (1 / Float(answers.count)) * Float(self.corrections)
            })
            .navigationBarTitle("Exam Result", displayMode: .inline)
        } // VStack
    }
}



//
//  ExamSubmittedAnswerView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 7/3/21.
//

import SwiftUI

struct ExamSubmittedAnswerView: View {
    @State var questions : [WordRealm]
    @State var answers : [String]
    @State var curIndex = 0
    var body: some View {
        HStack{
            Text("OUTPUT")
                .foregroundColor(Color(UIColor.init(hex: "#272343")))
                .fontWeight(.heavy)
                .padding([.leading, .bottom], 10)
            Spacer()
        }
        
        Form{
            Section(header:
                        HStack{
                            Text("Answer")
                                .padding()
                            
                            Spacer()
                            
                            Text("Typed")
                                .padding()
                            
                            Spacer()
                            
                            Text("History")
                                .padding()
                        })
            {
                ForEach (Array(answers.enumerated()), id: \.element) { index, answer in
                    List{
                        HStack{
                            Text(questions[index].word)
                            Spacer()
                            Text((answer.count == 0) ? "Not Submitted" : answer)
                            //                        Text(String(format: "\(wordObject.correctNum) / \(wordObject.testedNum)"))
                            Spacer()
                            Text(String(format: "\(questions[index].correctNum) / \(questions[index].testedNum)"))
                        }
                        .frame(width: .infinity, height: 30, alignment: .center)
                        .padding([.leading, .trailing], 15)
                    }
                }
            } // Form
        }
    }
}

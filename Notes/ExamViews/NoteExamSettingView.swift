//
//  NoteExamSettingView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 3/3/21.
//

import SwiftUI

struct NoteExamSettingView: View {
    @Binding var isEditing : Bool
    @Binding var prepTime : CGFloat
    @Binding var typingTime : CGFloat
    
    // Local Private Variables
     var typingMinimumValue : Float = 1.0
     var typingMaximumvalue : Float = 20.0
     var prepMinimumValue : Float = 0.1
     var prepMaximumvalue : Float = 10.0

    
    var body: some View {
         VStack {
            VStack{
                VStack{
                    Text("Typing Time")
                        .foregroundColor(.white)
                    
                    HStack {
                        Text(String(format: "%.1f", self.typingMinimumValue))
                            .foregroundColor(.white)
                        Slider(value: $typingTime,
                               in: 1.0 ... 20.0,
                               step: 0.1)
                        Text(String(format: "%.1f", self.typingMaximumvalue))
                            .foregroundColor(.white)
                    }
                    Text(String(format: "%.1f seconds", (self.typingTime)))
                        .foregroundColor(.white)
                    
                }
                .frame(alignment: .center)
                .padding(.bottom, 30)
                .padding([.leading, .trailing], 20)
                .transition(.scale)
                
                
                VStack{
                    Text("Preparation Time")
                        .foregroundColor(.white)
                    HStack {
                        Text(String(format: "%.1f", self.prepMinimumValue))
                            .foregroundColor(.white)
                        Slider(value: $prepTime,
                               in: 0.1 ... 10.0,
                               step: 0.1)
                        Text(String(format: "%.1f", self.prepMaximumvalue))
                            .foregroundColor(.white)
                    }
                    Text(String(format: "%.1f seconds", (self.prepTime)))
                        .foregroundColor(.white)
                    
                }
                .frame(alignment: .center)
                .padding(.bottom, 30)
                .padding([.leading, .trailing], 20)
                .transition(.scale)
                
                VStack{
                    Button(action: {
                        withAnimation {self.isEditing.toggle()}
                    }, label: {
                        Text("Confirm Settings")
                            .foregroundColor(.white)
                            .padding()
                            .border(Color.white, width: 1)
                    })
                    
                }
                .frame(alignment: .center)
                .padding(.bottom, 30)
                .padding([.leading, .trailing], 20)
                .transition(.scale)
            }
            .padding()
            .background(Color(UIColor.init(hex: "#272343")))
        }
    }
}

struct NoteExamSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NoteExamSettingView(isEditing: .constant(true),
                            prepTime: .constant(CGFloat(2.0)),
                            typingTime: .constant(CGFloat(2.0)))
    }
}


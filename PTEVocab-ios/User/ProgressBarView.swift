//
//  ProgressBarView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 7/3/21.
//

import SwiftUI

/// https://www.simpleswiftguide.com/how-to-build-a-circular-progress-bar-in-swiftui/
struct ProgressBarView: View {
    @Binding var corNum : Int
    @Binding var numAns : Int
    
    @State var progress : Float = 0.0
    
    var body: some View {
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
        .onAppear {
            self.progress = (1 / Float(self.numAns)) * Float(self.corNum)
            print("ProgressBarView: ", self.progress, "Given nums are: \(self.numAns) and \(self.corNum)")
        }
    }
}


//
//  LoadingView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 2/3/21.
//

import SwiftUI

struct LoadingView: View {
    @State var text = "Loading"
    @Binding var isPresented : Bool
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack{
            Image("PTEVocab")
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 40)
            
            Text("\(text)")
                .font(.system(size: 17)).bold()
                .transition(.slide)
                .onReceive(timer, perform: {(_) in
                    if self.text.count == "Loading...".count {
                        self.timer.upstream.connect().cancel()
                        self.text = "Complete!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isPresented.toggle()
                        }
                    } else {
                        self.text += "."
                    }
                })
                .foregroundColor(.white)
                .font(.system(size: 30, weight: .bold))
                .animation(Animation.spring(dampingFraction: 0.5).delay(0.1))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 50)
        .background(Color(UIColor.init(hex: "#272343")))
        .edgesIgnoringSafeArea([.top, .bottom])
        
    }
}


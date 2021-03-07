//
//  PrepBarView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 2/3/21.
//

import SwiftUI

struct PrepBarView: View {
    @State var isShowing = false
    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(Color.gray)
                .opacity(0.3)
                .frame(width: 345.0, height: 8.0)
            Rectangle()
                .foregroundColor(Color.blue)
                .frame(width: self.isShowing ? 345.0 * (((self.progress > 100.0) ? 100 : self.progress) / 100.0) : 0.0, height: 8.0)
                .animation(.linear(duration: 0.6))
        }
        .onAppear {
            self.isShowing = true
        }
        .cornerRadius(4.0)
    }
}

struct PrepBarView_Previews: PreviewProvider {
    static var previews: some View {
        PrepBarView(progress: .constant(25.0))
    }
}

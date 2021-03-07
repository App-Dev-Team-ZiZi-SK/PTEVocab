//
//  LoginView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 18/1/21.
//


import SwiftUI

struct LoginView: View {
    @State private var alert = false
    @State private var showPopUp: Bool = false
    
    var body: some View {
        VStack{
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            
            Image("PTEVocab")
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 40)
                .animation(Animation.easeOut(duration: 0.6).delay(0.1))
            
            SocialButtonView()
                .animation(Animation.easeOut(duration: 0.6).delay(0.1))
            
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
            
        } // VStack
        .padding(.horizontal, 50)
        .background(Color(UIColor.init(hex: "#272343")))
        .edgesIgnoringSafeArea([.top, .bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(isPresented: $alert, content: {
            Alert(title: Text("Message"), message: Text("Successfully Logged In"), dismissButton: .destructive(Text("OK")))
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

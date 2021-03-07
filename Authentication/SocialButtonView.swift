//
//  SocialButtonView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 20/1/21.
//

import SwiftUI

struct SocialButtonView: View {
    var body: some View {
        let signInSoical = SignInViewController()
        
        return ZStack {
            signInSoical
            VStack {
                // Google Login
                Button(action: {signInSoical.signInWithGoogle()},
                    label: {
                    Image("Login_g")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
                .buttonStyle(PlainButtonStyle())
                
                Spacer(minLength: 20)
                
                Button(action: {signInSoical.signInWithFacebook()}, label: {
                    Image("Login_fb")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
                .buttonStyle(PlainButtonStyle())
                
            }//vstack
        }// zstack
        .aspectRatio(3, contentMode: .fit)
    }
}

struct SocialButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SocialButtonView()
    }
}

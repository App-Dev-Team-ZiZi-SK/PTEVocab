//
//  SignInViewController.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 19/1/21.
//

import SwiftUI
import AWSMobileClient

struct SignInViewController: UIViewControllerRepresentable {
    let navController =  UINavigationController()
    
    func makeUIViewController(context: Context) -> UINavigationController {
        navController.setNavigationBarHidden(true, animated: false)
        let viewController = UIViewController()
        navController.addChild(viewController)
        return navController
    }
    
    func updateUIViewController(_ pageViewController: UINavigationController, context: Context)   {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: SignInViewController
        
        init(_ signInViewController: SignInViewController) {
            self.parent = signInViewController
        }
    }
    
    
}

// MARK: Sign In With Google Extension
extension SignInViewController {
    
    func signInWithGoogle() {
        signInWithIdentityProvider(with: "Google")
    }
    
    func signInWithFacebook() {
        signInWithIdentityProvider(with: "Facebook")
    }
    
    func signInWithIdentityProvider(with provider: String) {
        let hostedUIOptions = HostedUIOptions(scopes: [ "openid", "email"], identityProvider: provider)
        AWSMobileClient.default().showSignIn(navigationController: navController, hostedUIOptions: hostedUIOptions) { (userState, error) in
            if let error = error as? AWSMobileClientError {
                print(error.localizedDescription)
            }
            if let userState = userState {
                print("Status: \(userState.rawValue)")
                
                AWSMobileClient.default().getTokens { (tokens, error) in
                    if let error = error {
                        print("error \(error)")
                    } else if let tokens = tokens {
                        let claims = tokens.idToken?.claims
                        print("username? \(claims?["username"] as? String ?? "No username")")
                        print("cognito:username? \(claims?["cognito:username"] as? String ?? "No cognito:username")")
                        print("email? \(claims?["email"] as? String ?? "No email")")
                        updateUserStrings(theToken: tokens, with: provider)
                    }
                }
            }
            
        }
    }
    func updateUserStrings(theToken tokens : Tokens, with provider: String) {
        let claims = tokens.idToken?.claims
            UserData.shared.user_email = claims?["email"] as? String ?? "No email"
        UserData.shared.realmUserSync()
    }

}

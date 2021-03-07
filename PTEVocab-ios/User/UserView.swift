//
//  UserView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 20/1/21.
//

import SwiftUI
import AWSMobileClient
import RealmSwift

struct UserView: View {
    @ObservedObject private var userData: UserData = .shared
    @State var activeSheet: ActiveSheet? = nil
    let frame = Frame()
    
    var body: some View {
        NavigationView{
            VStack {
                VStack {
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            self.activeSheet = .Setting
                        }, label: {
                            Image("setting")
                                .resizable()
                                .frame(width: 70, height: 30, alignment: .bottomTrailing)
                                .padding(.trailing, 10)
                        })
                        
                        Button(action: {
                            Backend.shared.timedUpdate()
                            AWSMobileClient.default().signOut()
                        }, label: {
                            Image("signout_btn")
                                .resizable()
                                .frame(width: 70, height: 30, alignment: .bottomTrailing)
                                .padding(.trailing, 30)
                        })
                        .padding()
                    }
                    .padding(.top, 100)
                    
                    HStack {
                        Spacer(minLength: self.frame.SCREEN_WIDTH * 0.1)
                        Image("userProfile")
                            .resizable()
                            .frame(width: self.frame.SCREEN_WIDTH / 5, height: self.frame.SCREEN_WIDTH / 5)
                            .padding()
                        VStack(alignment: .leading, spacing: 6){
                            Text("Email: \(self.userData.user_email)")
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .scaledToFit()
                            
                            Text("Canberra is the best city!")
                                .fontWeight(.semibold)
                                .scaledToFit()
                        }
                        .scaledToFit()
                        Spacer()
                    }
                    
                    HStack{
                        VStack{
                            Text("\(self.userData.totalWordsCount)")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                                .padding(.bottom, 1)
                            Text("WORDS")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "rectangle.fill")
                                .resizable()
                        }
                        .frame(width: 5, height: 30)
                        .padding(.all, 10)
                        .foregroundColor(.black)
                        
                        VStack{
                            Text("\(self.userData.noteRealms.count)")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                                .padding(.bottom, 1)
                            Text("NOTES")
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                } // Vstack
                .background(Color(UIColor.init(hex: "#BAE8E8")))
                
                VStack{
                    VStack{
                        Text("TEST HISTORY")
                            .foregroundColor(Color(UIColor.init(hex: "#272343")))
                            .fontWeight(.heavy)
                        Text(String(format: "\(userData.totalCorrCount) / \(userData.totalTestCount)"))
                            .foregroundColor(Color(UIColor.init(hex: "#272343")))
                            .fontWeight(.heavy)
                    }
                    .padding([.bottom, .top], 40)
                    
                    ProgressBarView(corNum: $userData.totalCorrCount, numAns: $userData.totalTestCount)
                        .frame(width: 150.0, height: 150.0)
                    
                    Spacer()
                }
                .padding(.top, 50)
                .frame(height: self.frame.SCREEN_HEIGHT * 0.65)
            } //Vstack
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear(perform: {
                if self.userData.user_email == "" {
                    let realm = try! Realm()
                    let userRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: self.userData.userDataRealmID)!
                    print("userRealm: Email - \(userRealm.user_email)")
                    self.userData.user_email = userRealm.user_email
                }
            })
            .sheet(item: $activeSheet, content: { sheet in
                if sheet == .Setting{
                    PickerSettingView(activeSheet: $activeSheet)
                }
            })
        } //navigationView
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}

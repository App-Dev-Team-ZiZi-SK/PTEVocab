//
//  PickerSettingView.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 5/3/21.
//

import SwiftUI
import RealmSwift

struct PickerSettingView: View {
    @Binding var activeSheet: ActiveSheet?
    @ObservedObject var userData : UserData = .shared
    
    var body: some View {
        Form{
            Section(header: Text("GENDER")){
                Picker("Gender", selection: self.$userData.ttsVoice) {
                    Text("Random").tag("Random")
                    Text("Female").tag("Female")
                    Text("Male").tag("Male")
                }.pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("COUNTRY")){
                Picker("Accent", selection: self.$userData.ttsAccent) {
                    Text("Random").tag("Random")
                    Text("AU").tag("en-AU")
                    Text("US").tag("en-US")
                    Text("UK").tag("en-GB")
                }.pickerStyle(SegmentedPickerStyle())
            }
            
            Section{
                HStack{
                    Spacer()
                    Button (action: {
                        self.activeSheet = nil
                        // Create an object
                        let realm = try! Realm()
                        let userRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: userData.userDataRealmID)!
                        try! realm.write {
                            print("PickerSettingView Update TTS")
                            userRealm.ttsSetting_Voice = userData.ttsAccent
                            userRealm.ttsSetting_Accent = userData.ttsVoice
                        }
                    }, label: {
                        Text("Confirm")
                            .background(Color.green)
                            .foregroundColor(Color.white)
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        self.activeSheet = nil
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Spacer()
                }
            }
        }
    }
}

struct PickerSettingView_Previews: PreviewProvider {
    static var previews: some View {
        PickerSettingView(activeSheet: .constant(ActiveSheet.Setting))
    }
}

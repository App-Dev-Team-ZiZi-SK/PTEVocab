//
//  UserClasses.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 2/3/21.
//

import SwiftUI
import RealmSwift

// singleton object to store user data
class UserData : ObservableObject {
    static var shared = UserData()
    
    var userDataRealmID = ""
    var defaultImages = [String]()
    var ttsVoice = "F"
    var ttsAccent = "en-AU"
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    let urls = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "defaultCovers.bundle")!
    
    init(){
        for url in urls{
            defaultImages.append(url.path)
        }
        self.jsonEncoder.outputFormatting = .prettyPrinted
    }
    
    @Published var user_email: String = ""
    @Published var totalWordsCount  = 0
    @Published var totalCorrCount = 0
    @Published var totalTestCount = 0
    @Published var isSignedIn : Bool = false
    @Published var noteRealms : [NoteRealm] = []
    @Published var isAnyRealmModified : Bool = true
    
    /// Sync UserData on Local
    /// setData: Local data has the data of the user
    func realmUserSync(){
        
        print("syncImageRealm: ID - \(String(describing: self.userDataRealmID))")
        print("syncImageRealm: Email - \(String(describing: self.user_email))")
        
        let realm = try! Realm()
        let userRealm = realm.object(ofType: UserRealm.self, forPrimaryKey: self.userDataRealmID)!
            try! realm.write {
                print("syncImageRealm Update Email")
                userRealm.user_email = self.user_email
            }
        }

    }

/// Realm Class for the user
class UserRealm : Object, Identifiable, Decodable, Encodable {
    @objc dynamic var id : String =  UUID().uuidString
    @objc dynamic var user_email: String = ""
    @objc dynamic var ttsSetting_Voice: String = "F"
    @objc dynamic var ttsSetting_Accent: String = "en-AU"
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

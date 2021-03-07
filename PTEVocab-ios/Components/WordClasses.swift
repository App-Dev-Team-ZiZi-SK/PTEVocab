//
//  WordClasses.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 24/2/21.
//


import SwiftUI
import RealmSwift
import Amplify
import Combine

class WordsFile : ObservableObject {
    var id : String
    var fileKey : String
    var wordsList : [WordRealm]?
    var preSignedURL: URL?
    var decodedData: Data?
    var wordsCount = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(fileKey: String, id: String){
        self.fileKey = fileKey
        self.id = id
    }
    
    
    /// Download Json from S3 using preSignedURL.
    /// - Parameter completion: It Ensures the completion of transformation.
    func getWordFileWithPresignedURL(completion: @escaping (([WordRealm]?) -> () )) {
        let url = self.preSignedURL!
        print("WordFile Downloaded - \(self.fileKey)")
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            do {
                if let d = data {
                    let decodedLists = try UserData.shared.jsonDecoder.decode([WordRealm].self, from: d)
                    completion(decodedLists)
                } else {
                    print("No Data - No WordFile exist")
                    completion(nil)
                }
            } catch {
                print ("WordFile Error")
                completion(nil)
            }
        }.resume()
    }
    

    
    /// get preSignedURL for word file
    func getPreSignedURLWord(fileKey: String, completion: @escaping (Bool) -> ()){
        let accessLevel = StorageGetURLRequest.Options(accessLevel: .private)
        Amplify.Storage.getURL(
            key: fileKey,
            options: accessLevel,resultListener: { (event) in
                switch event {
                case let .success(url):
                    self.preSignedURL = url
                    completion(true)
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    completion(true)
                }
            })
    }
    
    /// Sync the retrieved words from Json file downloaded into Local NoteRealm
    func syncWordRealms(){
        print("syncWordRealms: ID - \(String(describing: self.id))")
        let realm = try! Realm()
        let userRealm = realm.object(ofType: NoteRealm.self, forPrimaryKey: self.id)!
        self.wordsCount = (self.wordsList?.count) ?? 0
        try! realm.write {
            // Successfully Wrote to the local
            print("syncWordRealms: Write wordsData")
            for word in self.wordsList! {
                userRealm.wordObjects.append(word)
            }
            userRealm.isWordsModified = false
            userRealm.wordsModifiedAt = Date()
        }
    }
    
    /// Get URL to download a file and decode into WordObject and append it to its NoteRealm.
    func serverToLocal(){
        // If not a default image
        print("loadImage: It is not default Image")
        DispatchQueue.main.async {
            self.getPreSignedURLWord(fileKey: self.fileKey) {result in
                if (result){
                    print("Success: Retrieved preSignedURL of \(String(describing: self.fileKey))")
                } else {
                    print("Failed to Retrieve preSignedURL of \(String(describing: self.fileKey))")
                    return
                }
                // Request the data and sync it to realmObject.
                self.getWordFileWithPresignedURL() {result in
                    if ((result) != nil){
                        print("Success: getWordFileWithPresignedURL - \(self.fileKey)")
                        self.wordsList = result!
                        self.syncWordRealms()
                    } else {
                        print("getData Error - No WordFile exist")
                    }
                }
                return
            }
        }
    }
}

/// Class for each word
class WordRealm : Object, Identifiable, Decodable, Encodable {
    @objc dynamic var id : String =  UUID().uuidString
    @objc dynamic var word: String = ""
    @objc dynamic var comment: String = ""
    @objc dynamic var correctNum: Int = 0
    @objc dynamic var testedNum: Int = 0
    @objc dynamic var isFavorited: Bool = false
    @objc dynamic var playedTimes: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

/// Sheet Control Purpose
enum ActiveSheet: Identifiable {
    case Edit, Setting
    
    var id: Int {
        hashValue
    }
}

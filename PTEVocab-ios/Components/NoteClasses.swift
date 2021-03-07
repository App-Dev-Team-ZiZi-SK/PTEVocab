//
//  NoteClasses.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 15/1/21.
//
import SwiftyJSON
import SwiftUI
import RealmSwift
import Combine
import Amplify


class NoteRealm : Object, Identifiable {
    @objc dynamic var id : String = UUID().uuidString
    // NoteRealm Cover
    @objc dynamic var noteName : String = ""
    @objc dynamic var noteRealmDescription : String = ""

    // NoteRealm File keys and Data
    @objc dynamic var imageKey : String? = nil
    @objc dynamic var wordsKey: String? = nil
    @objc dynamic var imageData : Data? = nil
    
    // NoteRealm Update Parameters
    @objc dynamic var isCoverModified: Bool = false
    @objc dynamic var isImageModified: Bool = false
    @objc dynamic var isWordsModified: Bool = false
    @objc dynamic var coverModifiedAt: Date = Date()
    @objc dynamic var imageModifiedAt: Date = Date()
    @objc dynamic var wordsModifiedAt: Date = Date()
    
    // To be under bin folder - ensure update modifiedAt when mark this
    @objc dynamic var isNoteDeleted: Bool = false
 
    // Extra parameters
    var filePath : URL? = nil
    private var preSignedURL : URL?
    var wordObjects = RealmSwift.List<WordRealm>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func imageUpdater (_ imageData : Data?){
        self.imageData = imageData ?? nil
    }
    
    /// Transform Note to NoteRealm
    func noteToRealm (_ note: Note) {
        self.id = note.id
        self.noteName = note.name
        self.noteRealmDescription = note.description ??  ""
        self.imageKey = note.imageKey
        self.wordsKey = note.wordsKey

    }
    
    /// Transform NoteRealm to Note
    func realmToNote(_ noteRealm: NoteRealm) -> Note {
        let note = Note(id: noteRealm.id,
                        name: noteRealm.noteName,
                        description: noteRealm.noteRealmDescription,
                        imageKey: noteRealm.imageKey,
                        wordsKey: noteRealm.wordsKey,
                        coverModifiedAt: dateToString(noteRealm.coverModifiedAt),
                        imageModifiedAt: dateToString(noteRealm.imageModifiedAt),
                        wordsModifiedAt: dateToString(noteRealm.wordsModifiedAt),
                        isDeleted: noteRealm.isNoteDeleted)
        return note
    }
    
    func dateToString(_ date: Date?) -> String {
        // Set and conver to the given format DateTime
        let tempDate = (date == nil) ? Date() : date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: tempDate!)
    }
    
    func stringToDate(date: String?) -> Date {
        // Set and conver to the given format DateTime
        if date == nil {return Date()}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return (dateFormatter.date(from: date!)!)
    }
    
    func coverImageKeyCreate(){
        // This is not triggerred when the image is default hence no worry about imageData being null
        let pathName =  "images/"
        self.imageKey = pathName +  UUID().uuidString + ".png"
    }
    
    func wordsFileKeyCreate(){
        let pathPrefix =  "notes/"
        self.wordsKey = pathPrefix + UUID().uuidString + ".json" // private/UserID/notes...
    }
    
    /// Transform [WordObject] to Json Fomrat
    /// - Parameter words: words: [WordObject]
    func saveToJson() {
        let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        self.filePath = pathDirectory.appendingPathComponent(self.noteName)
        do {
            let data = try? UserData.shared.jsonEncoder.encode(self.wordObjects)
            try data!.write(to: filePath!)
            print("Success to write at \(String(describing: self.filePath))")
        } catch {
            print("Failed to write Filename \(error)")
        }
    }
}


/// Device Frame Variables
struct Frame {
    let device = UIDevice.current.localizedModel
    let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
}

class Note : Identifiable, ObservableObject {
    var id : String
    var owner: String?
    var name : String
    var description : String?
    var imageKey : String?
    var wordsKey: String?

    var coverModifiedAt : String?
    var imageModifiedAt : String?
    var wordsModifiedAt : String?
    var isDeleted: Bool?
    @Published var image : Image?
    
    init(id: String,
         name: String,
         owner: String? = nil,
         description: String? = nil,
         imageKey: String? = nil,
         wordsKey: String? = nil,
         coverModifiedAt : String? = nil,
         imageModifiedAt : String? = nil,
         wordsModifiedAt : String? = nil,
         isDeleted: Bool = false) {

        self.id = id
        self.owner = owner
        self.name = name
        self.description = description
        self.imageKey = imageKey
        self.wordsKey = wordsKey

        self.coverModifiedAt = coverModifiedAt
        self.imageModifiedAt = imageModifiedAt
        self.wordsModifiedAt = wordsModifiedAt
        self.isDeleted = isDeleted
    }
    
    /// NoteData: GraphQL data schema
    convenience init(from data: NoteData) {
        self.init(id: data.id,
                  name: data.note_name,
                  owner: data.note_owner,
                  description: data.note_description,
                  imageKey: data.note_image_key,
                  wordsKey: data.note_file_key,
                  coverModifiedAt: data.note_cover_modified_at,
                  imageModifiedAt: data.note_image_modified_at,
                  wordsModifiedAt: data.note_words_modified_at,
                  isDeleted: data.note_isDeleted ?? false)
        
        // store API object for easy retrieval later
        self._data = data
    }
    
    fileprivate var _data : NoteData?

    var data : NoteData {
        if (_data == nil) {
            _data = NoteData(id: self.id,
                             note_owner: self.owner,
                             note_name: self.name,
                             note_description: self.description,
                             note_image_key: self.imageKey,
                             note_file_key: self.wordsKey,
                             note_cover_modified_at: self.coverModifiedAt,
                             note_image_modified_at: self.imageModifiedAt,
                             note_words_modified_at: self.wordsModifiedAt,
                             note_isDeleted: self.isDeleted)
        }
        return _data!
    }
    
    /// It compares a new note from server and local to check which parts of note requires update (renew)
    func UpdateChecker (_ givenObject: NoteRealm, _ givenNote: Note) -> UpdateCheckList {
        var updateChecker = UpdateCheckList()
        print("UpdateChecker Checking \(givenNote.name)")
        

        if !updateChecker.needCoverUpdate!{
            if givenObject.coverModifiedAt >= givenObject.stringToDate(date: givenNote.coverModifiedAt){
                print("Skip Cover Update")
            } else {
                updateChecker.needCoverUpdate = true
                updateChecker.needUpdate = true
            }
        }
        
        if !updateChecker.needImageUpdate!{
            if givenObject.imageModifiedAt >= givenObject.stringToDate(date: givenNote.imageModifiedAt){
                print("Skip Image Update")
            } else {
                updateChecker.needImageUpdate = true
                updateChecker.needUpdate = true
            }
        }
        
        if !updateChecker.needWordsUpdate!{
            if givenObject.wordsModifiedAt >= givenObject.stringToDate(date: givenNote.wordsModifiedAt){
                print("Skip Words Update")
            } else {
                updateChecker.needWordsUpdate = true
                updateChecker.needUpdate = true
            }
        }
        return updateChecker
    }
}

/// To track which part of note requires an update
struct UpdateCheckList {
    var needUpdate : Bool = false
    var needCoverUpdate : Bool?
    var needImageUpdate : Bool?
    var needWordsUpdate : Bool?
    
    init(_ need: Bool? = false, _ cover: Bool? = false, _ image: Bool? = false, _ words: Bool? = false){
        self.needUpdate = need!
        self.needCoverUpdate = cover
        self.needImageUpdate = image
        self.needWordsUpdate = words
    }
}

enum updateMode{
    case cover
    case image
    case words
}

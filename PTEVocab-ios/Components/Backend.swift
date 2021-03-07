//
//  Backend.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 15/1/21.

import UIKit
import Amplify
import AmplifyPlugins
import AWSMobileClient
import RealmSwift

class Backend {
    @Published var backendID = ""
    static let shared = Backend()
    static func initialize() -> Backend {
        print("Backend: Init called")
        return .shared
    }
    private init() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            // Configure Plugins
            try Amplify.configure()
            
            print("Initial Status: Initialized Amplify");
        } catch {
            print("Initial Status: Could not initialize Amplify: \(error)")
        }
        // initialize client
        initializeAWSMobileClient()
        addUserStateListener()
    }
    
    /// Intialize only Once in the beginning - addUserStateListener after all.
    func initializeAWSMobileClient(){
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                case .signedIn: // is Signed IN
                    print("Initial Status: Logged In")
                    self.updateUserData(withSignInStatus: true)
                case .signedOut: // is Signed OUT
                    print("Initial Status: Logged Out")
                    self.updateUserData(withSignInStatus: false)
                case .signedOutUserPoolsTokenInvalid: // User Pools refresh token INVALID
                    print("Initial Status: User Pools refresh token is invalid or expired.")
                    self.updateUserData(withSignInStatus: false)
                default:
                    // When the app launched for the first time -> ID is nill
                    self.signOut()
                    self.updateUserData(withSignInStatus: false)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// AWSMobileClient - a realtime notifications for user state changes after its initialization: initializeAWSMobileClient
    func addUserStateListener() {
        AWSMobileClient.default().addUserStateListener(self) { (userState, info) in
            print("Add useruserstate:\(userState) and Info:\(info)")
            switch (userState) {
            case .signedIn:
                print("Listener status change: signedIn")
                self.updateUserData(withSignInStatus: true)
            case .signedOut:
                print("Listener status change: signedOut")
                self.updateUserData(withSignInStatus: false)
            case .signedOutFederatedTokensInvalid:
                print("Listener status change: signedOutFederatedTokensInvalid")
                self.updateUserData(withSignInStatus: false)
            default:
                print("Listener: unsupported userstate")
                self.updateUserData(withSignInStatus: false)
            }
        }
    }
    
    /// Update the internal user data to ensure the segregation among the different users in one device.
    func updateUserData(withSignInStatus status : Bool) {
        DispatchQueue.main.async() {
            UserData.shared.isSignedIn = status
            if UserData.shared.isSignedIn {
                print("updateUserData: Logged")
                self.queryNotes()
            } else {
                print("updateUserData: Not Logged")
                UserData.shared.noteRealms = []
            }
        }
    }
    
    /// Sets default realm configuration per user by adding one's user name in the path.
    func setDefaultRealmForUser(username: String) {
        var config = Realm.Configuration()
        
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        print("Realm URL : \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
    }
    
    
    /// Queries Notes on DybamoDB in AWS
    func queryNotes(){
        _ = Amplify.API.query(request: .list(NoteData.self)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let notesData):
                    print("queryNotes: Successfully retrieved list of Notes")
                    
                    Backend.shared.backendID = AWSMobileClient.default().getIdentityId().result! as String
                    
                    self.setDefaultRealmForUser(username: self.backendID)
                    let realm = try! Realm()
                    
                    let userData = UserData.shared
                    
                    let userRealms = realm.objects(UserRealm.self)
                    if userRealms.count != 0 {
                        let tempUserRealm = userRealms.first
                        userData.userDataRealmID = tempUserRealm!.id
                        userData.ttsAccent = tempUserRealm!.ttsSetting_Accent
                        userData.ttsVoice = tempUserRealm!.ttsSetting_Voice
                    } else {
                        let tempUserRealm = UserRealm()
                        userData.userDataRealmID = tempUserRealm.id
                        try! realm.write {
                            realm.add(tempUserRealm)
                        }
                    }
                    
                    // Notes Query
                    for n in notesData {
                        // Setup for data transformation.
                        let note = Note.init(from: n)
                        var updateCheckList = UpdateCheckList()
                        
                        // Get local NoteRealm
                        let tempRealm = realm.object(ofType: NoteRealm.self, forPrimaryKey: note.id)
                        if tempRealm != nil {
                            updateCheckList = note.UpdateChecker(tempRealm!, note)
                        } else {
                            print("queryNotes: New one -> Save")
                            updateCheckList = UpdateCheckList(true, true, true, true)
                        }
                        
                        // Check if the local NoteRealm needs to be updated
                        if !updateCheckList.needUpdate {
                            print("queryNotes: No Update Required")
                            continue
                        }
                        
                        // Delete local NoteRealm
                        try! realm.write {
                            print("queryNotes: Delete Local NoteRealm")
                            if (tempRealm != nil) {
                                realm.delete(tempRealm!)
                            }
                        }
                        
                        // Initialize the queried note into NoteRealm
                        let noteRealm = NoteRealm()
                        noteRealm.noteToRealm(note)
                        
                        // Save the note to local
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(noteRealm)
                            print("queryNotes: Saved \(noteRealm.noteName)")
                        }
                        
                        // Load image and words file from the server
                        if updateCheckList.needImageUpdate!{
                            UserImage(imageKey: note.imageKey, id: note.id, imgData: nil, isJustDownloaded: true).loadImage()
                        }
                        if updateCheckList.needWordsUpdate!{
                            WordsFile(fileKey: note.wordsKey!, id: note.id).serverToLocal()
                        }
                    }
                    
                    
                    
                case .failure(let error):
                    print("queryNotes: Can not retrieve result - error  \(error.errorDescription)")
                }
            case .failure(let error):
                print("queryNotes: Can not retrieve Notes - error \(error)")
            }
        }
    }
    
    /// Upload a new note added by the user to DynamoDB in AWS
    func createNote(note: Note, completion: @escaping (Bool) -> Void) {
        UserData.shared.isAnyRealmModified = true
        _ = Amplify.API.mutate(request: .create(note.data)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("createNote: Uploaded \n Data:\(data)")
                    completion(true)
                case .failure(let error):
                    print("createNote: Failed to Upload \n Error:\(error.errorDescription)")
                    completion(false)
                }
            case .failure(let error):
                print("createNote: Failed to Upload \n Error:\(error)")
            }
        }
    }
    
    /// Edit  a new note added by the user to DynamoDB in AWS
    func editNote(note: Note, completion: @escaping (Bool) -> Void) {
        //let note = noteRealm.realmToNote(noteRealm)
        // use note.data to access the NoteData instance
        _ = Amplify.API.mutate(request: .update(note.data)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully edited note: \(data)")
                    self.uploadWrapperFunction(id: note.id, mode: updateMode.image)
                    completion(true)
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    completion(false)
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                return
            }
        }
    }
    
    /// Delete the relevant note both on server and local
    func deleteNote(realmToDeleteID: String) {
        let realm = try! Realm()
        let realmToDelete = realm.object(ofType: NoteRealm.self, forPrimaryKey: realmToDeleteID)!
        let note = realmToDelete.realmToNote(realmToDelete)
        
        // Delete Local Data
        DispatchQueue(label: "background").async {
            try! realm.write {
                print("deleteNote: Deleted NoteRealm")
                realm.delete(realmToDelete)
            }
        }
        
        // Delete Image and Words Files
        let tempImageKey : String? = note.imageKey
        let tempWordsKey : String! = note.wordsKey
        if (tempImageKey == nil) {
            deleteStorageFiles(keysToDelete: [tempWordsKey])
        } else {
            deleteStorageFiles(keysToDelete: [tempImageKey!, tempWordsKey])
        }
        
        // Delete Server Data
        _ = Amplify.API.mutate(request: .delete(note.data)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    print("Successfully deleted note: \(data)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
        
    }
    
    /// Delete a WordRealm async
    func deleteWord(wordObjectID: String) {
        let realm = try! Realm()
        let wordObject = realm.object(ofType: WordRealm.self, forPrimaryKey: wordObjectID)!
        let realmRef = ThreadSafeReference(to: wordObject)
        DispatchQueue(label: "background").async {
            guard let realm = try? Realm(),let wordObject = realm.resolve(realmRef) else {
                print("timedUpdate: realm not found")
                return // person was deleted
            }
            try! realm.write {
                print("deleteWord: Deleted from Local")
                realm.delete(wordObject)
//                noteObject.isWordsModified = true
//                noteObject.wordsModifiedAt = Date()
            }
        }
        // Mark Updates
//        UserData.shared.totalWordsCount -= 1
    }
    
    /// Add a WordRealm async
    func addWord(parentNoteID: String, wordObject: WordRealm) {
        let realm = try! Realm()
        let noteObject = realm.object(ofType: NoteRealm.self, forPrimaryKey: parentNoteID)!
        // Delete Local Data
        DispatchQueue.main.async {
            try! realm.write {
                print("addWord: Added WordRealm")
                noteObject.wordObjects.append(wordObject)
                noteObject.isWordsModified = true
                noteObject.wordsModifiedAt = Date()
            }
        }
        // Mark Updates
        UserData.shared.totalWordsCount += 1
    }

    
    /// Upload an image chosen by the user to S3 in AWS
    /// https://stackoverflow.com/a/57656111/7651048 - use presidnged url
    func uploadImageFile(imageFileKey: String, imageData: Data, noteID: String, completion: @escaping (Bool) -> Void){
        let accessLevel = StorageUploadDataRequest.Options(accessLevel: .private)
        Amplify.Storage.uploadData(
            key: imageFileKey,
            data: imageData,
            options: accessLevel,
            progressListener: { progress in
                //print("Image Upload Progress: \(progress)")
            }, resultListener: { event in
                switch event {
                case let .success(data):
                    print("ImageFile Uploading Completed: \(data)")
                    self.uploadWrapperFunction(id: noteID, mode: updateMode.image)
                    completion(true)
                case let .failure(storageError):
                    print("ImageFile Uploading Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    completion(false)
                }
            }
        )
    }
    
    /// Upload a WordsFile chosen by the user to S3 in AWS
    func uploadWordsFile(wordFileKey: String, filePath: URL, noteID: String, completion: @escaping (Bool) -> Void){
        let accessLevel = StorageUploadFileRequest.Options(accessLevel: .private)
        Amplify.Storage.uploadFile(
            key: wordFileKey,
            local: filePath,
            options: accessLevel,
            progressListener: { progress in
                //print("File Upload Progress: \(progress)")
            }, resultListener: { event in
                switch event {
                case let .success(data):
                    print("WordFile Uploading Completed: \(data)")
                    self.uploadWrapperFunction(id: noteID, mode: updateMode.words)
                    completion(true)
                case let .failure(storageError):
                    print("WordFile Uploading Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    completion(false)
                }
            }
        )
    }
    
    
    func deleteStorageFiles(keysToDelete: [String]!){
        let accessLevel = StorageRemoveRequest.Options(accessLevel: .private)
        for key in keysToDelete {
            Amplify.Storage.remove(
                key: key,
                options: accessLevel,
                resultListener: { event in
                    switch event {
                    case .success(_):
                        print("deleteStorageFiles: Deleted Key:\(key)")
                    case let .failure(storageError):
                        print("deleteStorageFiles: Failed to delete Key:\(key): \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    }
                }
            )
        }
        
    }
    
    /// Signout: Excute update before fully signout
    public func signOut() {
        //self.timedUpdate()
        print("signOut: Update Before SignOut")
        _ = Amplify.Auth.signOut() { (result) in
            switch result {
            case .success:
                print("signOut: Successfully signed out")
            case .failure(let error):
                print("signOut: failed with error \(error)")
            }
        }
    }
    
    /// This function gets called only when the upload is successful.
    /// When failed -> upload functions will be re-called in the near future.
    func uploadWrapperFunction(id: String, mode: updateMode){
        let realm = try! Realm()
        let userRealm = realm.object(ofType: NoteRealm.self, forPrimaryKey: id)!
        try! realm.write {
            switch mode {
            case .image:
                userRealm.isImageModified = false
            case .words:
                userRealm.isWordsModified = false
            case .cover:
                userRealm.isCoverModified = false
            }
        }
    }
    
    /// Refresh the list of NoteRealms
    func realmUpdater(){
        if UserData.shared.isAnyRealmModified || UserData.shared.noteRealms.count == 0 {
            DispatchQueue.main.async(){
                let realm = try! Realm()
                let wrapper = realm.objects(NoteRealm.self)
                var wordsCount = 0
                var corrCount = 0
                var testCount = 0
                print("realmUpdater Called")
                UserData.shared.noteRealms = []
                for i in 0..<wrapper.count {
                    wordsCount += wrapper[i].wordObjects.count
                    corrCount += wrapper[i].wordObjects.sum(ofProperty: "correctNum")
                    testCount += wrapper[i].wordObjects.sum(ofProperty: "testedNum")
                    UserData.shared.noteRealms.append(wrapper[i])
                }
                UserData.shared.isAnyRealmModified = false
                UserData.shared.totalWordsCount = wordsCount
                UserData.shared.totalCorrCount = corrCount
                UserData.shared.totalTestCount = testCount
            }
        }
    }
    
    /// Update objects that are modified in every other n seconds
    func timedUpdate(){
        let realm = try! Realm()
        let wrapper = realm.objects(NoteRealm.self).filter("isCoverModified == true OR isWordsModified == true OR isImageModified == true")
        if wrapper.count == 0 {
            print("timedUpdate: No Notes to Update")
            return
        }
        print("timedUpdate: Updating \(wrapper.count) notes")
        let realmRef = ThreadSafeReference(to: wrapper)
        DispatchQueue(label: "background").async {
            guard let realm = try? Realm(),let userRealms = realm.resolve(realmRef) else {
                print("timedUpdate: realm not found")
                return // person was deleted
            }
            
            try! realm.write {
                for userRealm in userRealms {
                    // Keep the order of update
                    if userRealm.isImageModified {
                        userRealm.isImageModified = true
                        Backend.shared.uploadImageFile(imageFileKey: userRealm.imageKey!, imageData: userRealm.imageData!, noteID: userRealm.id){result in
                            if(!result){print("timeUpdate: Upload Cover pic Failed")}
                        }
                    }
                    
                    if userRealm.isWordsModified {
                        userRealm.saveToJson()
                        userRealm.isWordsModified = false
                        Backend.shared.uploadWordsFile(wordFileKey: userRealm.wordsKey!, filePath: userRealm.filePath!, noteID: userRealm.id){result in
                            if(!result){print("timeUpdate: Upload Words File Failed")}
                        }
                    }
                    if userRealm.isCoverModified{
                        let note = userRealm.realmToNote(userRealm)
                        userRealm.isCoverModified = false
                        Backend.shared.editNote(note: note){result in
                            if(!result){print("timeUpdate: Upload Table Failed")}
                        }
                    }
                }
            }
        }
    }
}


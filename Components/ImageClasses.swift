//
//  ImageClasses.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 31/1/21.
//


import SwiftUI
import Combine
import Amplify
import RealmSwift

class UserImage: NSObject, ObservableObject {
    var id : String?        // To find/edit the image
    var imageKey : String?  // ImageKey retrieved from a table.
    var preSignedURL : URL? // URL retrieved from AWS
    var imageLoaded : Bool = false
    let prefix = "DefaultImages://"
    var isJustDownloaded : Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    @Published var uiImage : UIImage?
    
    // Two ways of using init:
    //      Adding a new note: imageKey is nil and generate random Images
    //      Load from an existing note
    init(imageKey: String?, id: String?, imgData: Data?, isJustDownloaded: Bool = false){
        // Assign default images in case the key is null
        if imageKey == nil{
            print("UserImage Init : imageRandomPicker Called")
            let defaultImagePath = UserData.shared.defaultImages.randomElement()!
            self.imageKey = self.prefix + defaultImagePath.components(separatedBy: "/").last!
            self.uiImage = UIImage(contentsOfFile: defaultImagePath)
            self.imageLoaded = false
            self.id = id
            return
        }
        
        if (imgData != nil){
            self.uiImage = UIImage(data:imgData!)
        }
        if (isJustDownloaded){
            self.isJustDownloaded = isJustDownloaded
        }
        self.id = id
        self.imageKey = imageKey
        print("UserImage : Init Called")
    }
    
    /// Sync the loaded image to its NoteRealm
    func syncImageRealm(isDefault : Bool){
        print("syncImageRealm: ID - \(String(describing: self.id))")
        let realm = try! Realm()
        let userRealm = realm.object(ofType: NoteRealm.self, forPrimaryKey: self.id)!
        try! realm.write {
            userRealm.imageData = self.uiImage?.pngData()
            userRealm.imageKey = self.imageKey
            if !isDefault {
                if (self.isJustDownloaded) {userRealm.isImageModified = false}
                else {userRealm.isImageModified = true}
                userRealm.imageModifiedAt = Date()
            }
        }
    }
    
    /// Called after getPreSignedURL to download an image
    func getImageDataWithPresignedURL(completion: @escaping (Bool) -> ()){
        URLSession.shared.dataTaskPublisher(for: self.preSignedURL!)
            .map { $0.data }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let downloadedData = $0{
                    if downloadedData.count > 500 {
                        print("Image Downloaded: \(downloadedData.count) byte")
                        self!.uiImage = UIImage(data: downloadedData)
                        self!.imageLoaded = true
                        UserData.shared.isAnyRealmModified = true
                        completion(true)
                        return
                    }
                }
                print("Image Download Failed")
                self!.imageLoaded = false
                self!.imageRandomPicker(id: self!.id)
                completion(true)
            }
            .store(in: &cancellables)
    }
    
    /// Get presignedURL for downloading an image
    func getImagePreSignedURL(imageKey: String, completion: @escaping (Bool) -> ()){
        let accessLevel = StorageGetURLRequest.Options(accessLevel: .private)
        Amplify.Storage.getURL(
            key: imageKey,
            options: accessLevel,resultListener: { (event) in
                switch event {
                case let .success(url):
                    self.preSignedURL = url
                    self.imageLoaded = true
                    completion(true)
                case let .failure(storageError):
                    // Has no image on the server
                    self.imageRandomPicker(id: self.id)
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    completion(true)
                }
            })
    }
    
    /// Load from the server if the imageKey is not default.
    func loadImage() {
        guard self.imageKey != nil else {
            return
        }
        // Check if it is a default image - No need to download from server
        if self.isDefault(givenImageKey: self.imageKey!){
            print("loadImage: It is default Image")
            let parsedImage = self.defaultImageParser(givenImageKey: self.imageKey!)
            self.uiImage = UIImage(contentsOfFile: parsedImage)
            self.imageLoaded = true
            
            self.syncImageRealm(isDefault: true)
            return
        }
        // If not a default image - Need to download from server
        print("loadImage: It is not default Image")
        DispatchQueue.main.async {
            self.getImagePreSignedURL(imageKey: self.imageKey!) {result in
                if (result){
                    print("Success: Retrieved preSignedURL of \(String(describing: self.imageKey))")
                } else {
                    print("Failed to Retrieve preSignedURL of \(String(describing: self.imageKey))")
                    // If no url -> image does not exist on the server
                    // Hence generate a default image
                    self.imageRandomPicker(id: self.id)
                    self.syncImageRealm(isDefault: true)
                    return
                }
                // Request the data and sync it to realmObject.
                self.getImageDataWithPresignedURL() {result in
                    if (result){
                        self.syncImageRealm(isDefault: false)
                    } else {
                        print("getData Error!")
                    }
                }
                return
            }
        }
    }
    
    /// Pick a random image from default images on local data
    func imageRandomPicker(id: String?) {
        let chosenImage =  UserData.shared.defaultImages.randomElement()!
        self.imageKey = self.defaultImageKeyCreate(ImagePath: chosenImage)
        self.uiImage = UIImage(contentsOfFile: chosenImage)
        print("UserImage : ImageKey is Null - imageRandomPicker triggered")
        self.imageLoaded = true
        self.id = id
        UserData.shared.isAnyRealmModified = true
    }
    
    /// Check if the given imageKey is a default image
    func isDefault(givenImageKey: String) -> Bool {
        // If default Image -> get the image
        if givenImageKey.hasPrefix(self.prefix){return true}
        else {return false}
    }
    
    /// Default images: "DefaultImages://ImageName -> return its local path in String format
    func defaultImageParser(givenImageKey: String?) -> String {
        // It is default image - parse by len of prefix
        let imageName = givenImageKey!.dropFirst(prefix.count)
        for defImage in UserData.shared.defaultImages {
            if defImage.hasSuffix(imageName) {
                return defImage
            }
        }
        // If cannot find the defImage, pick one and return the path
        self.imageKey = UserData.shared.defaultImages.randomElement()!
        print("defulatImageParse: \(String(describing: self.imageKey))")
        return self.imageKey!
    }
    
    /// Generates default imagekey before uploading its note to server
    func defaultImageKeyCreate(ImagePath: String) -> String {
        let token = ImagePath.components(separatedBy: "/")
        let suffix = token.last!
        print("defaultImageKeyCreate : \(self.prefix+suffix)")
        return self.prefix+suffix
    }
}

struct ImageOverlay: View {
    private var imageName : String
    init(imgName : String = "go"){
        self.imageName = imgName
    }
    var body: some View {
        ZStack {
            Image(self.imageName)
                .resizable()
        }
    }
}

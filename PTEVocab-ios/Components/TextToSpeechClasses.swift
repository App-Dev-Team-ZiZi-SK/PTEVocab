//
//  TextToSpeechClasses.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 25/1/21.
//  https://medium.com/google-cloud/how-to-integrate-google-cloud-text-to-speech-api-into-your-ios-app-140ab7be42ae

import AVFoundation



class SpeechService: NSObject, AVAudioPlayerDelegate {
    static let shared = SpeechService()
    
    private(set) var busy: Bool = false
    
    private var player: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    private var voiceSetter = VoiceGenerator()
    
   
    func speak(text: String, completion: @escaping () -> Void) {
        guard !self.busy else {
            print("Speech Service busy!")
            completion()
            return
        }
        
        self.busy = true
        
        DispatchQueue.global(qos: .background).async {
            let postData = self.buildPostData(text: text)
            let headers = ["X-Goog-Api-Key": ApiKeys().tts_APIKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: ApiKeys().tts_APIUrl, postData: postData, headers: headers)

            // Get the `audioContent` (as a base64 encoded string) from the response.
            guard let audioContent = response["audioContent"] as? String else {
                print("Invalid response: \(response)")
                self.busy = false
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            // Decode the base64 string into a Data object
            guard let audioData = Data(base64Encoded: audioContent) else {
                self.busy = false
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.completionHandler = completion
                self.player = try! AVAudioPlayer(data: audioData)
                self.player?.delegate = self
                self.player!.play()
            }
        }
    }
    
    private func buildPostData(text: String) -> Data {
        let chosenVoice = UserData.shared.ttsAccent
        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": (chosenVoice.datatypeValue == "Random") ? voiceSetter.randomAccent() : chosenVoice.datatypeValue
        ]
        
        let theVoice = setVoice(gender: UserData.shared.ttsVoice, accent: UserData.shared.ttsAccent)
        
        voiceParams["name"] = theVoice.datatypeValue
        
        print("Speech Option: \(theVoice)")
        
        let params: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceParams,
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16"
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    // Just a function that makes a POST request.
    private func makePOSTRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        
        self.completionHandler!()
        self.completionHandler = nil
    }
    
    func setVoice(gender: String, accent: String) -> String {
        if (gender == "Random") && (accent == "Random") {
            return voiceSetter.randomVoices.randomElement()!.randomElement()!.randomElement()!
            }
        
        if (gender == "Random"){
            print("Random Voice")
            if (accent == "en-AU") {return voiceSetter.randomVoices.randomElement()![0].randomElement()!}
            if (accent == "en-US") {return voiceSetter.randomVoices.randomElement()![1].randomElement()!}
            if (accent == "en-GB") {return voiceSetter.randomVoices.randomElement()![2].randomElement()!}
        }
        
        if (accent == "Random") {
            print("Random Accent")
            if (gender == "Female") {return voiceSetter.femaleVoices.randomElement()!.randomElement()!}
            else {return voiceSetter.maleVoices.randomElement()!.randomElement()!}
        }
        
        // Both not random
        if (accent == "en-AU"){
            if (gender == "Female") {return voiceSetter.auFemale.randomElement()!}
            else {return voiceSetter.auMale.randomElement()!}
        } else if (accent == "en-US"){
            if (gender == "Female") {return voiceSetter.usFemale.randomElement()!}
            else {return voiceSetter.usMale.randomElement()!}
        } else {
            if (gender == "Female") {return voiceSetter.gbFemale.randomElement()!}
            else {return voiceSetter.gbMale.randomElement()!}
        }
        //return voiceSetter.randomVoices.randomElement()![0].randomElement()!
    }
}

class VoiceGenerator {
    let auFemale = ["en-AU-Wavenet-A", "en-AU-Wavenet-C"]
    let auMale = ["en-AU-Wavenet-B", "en-AU-Wavenet-D"]
    let usFemale = ["en-US-Wavenet-C", "en-US-Wavenet-E", "en-US-Wavenet-F", "en-US-Wavenet-G", "en-US-Wavenet-H"]
    let usMale = ["en-US-Wavenet-A", "en-US-Wavenet-B", "en-US-Wavenet-D", "en-US-Wavenet-I", "en-US-Wavenet-J"]
    let gbFemale = ["en-GB-Wavenet-A", "en-GB-Wavenet-C", "en-GB-Wavenet-F"]
    let gbMale = ["en-GB-Wavenet-B", "en-GB-Wavenet-D"]
    
    var femaleVoices : [[String]]
    var maleVoices : [[String]]
    var randomVoices : [[[String]]]
    init (){
        femaleVoices = [auFemale, usFemale, gbFemale]
        maleVoices = [auMale, usMale, gbMale]
        randomVoices = [femaleVoices, maleVoices]
    }
    func randomAccent() -> String{
        return ["en-AU", "en-US", "en-GB"].randomElement()!
    }
}

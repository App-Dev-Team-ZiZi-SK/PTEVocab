//
//  PlayWord.swift
//  PTEVocab
//
//  Created by Sungkwon Lee on 25/1/21.
//

// https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#response-body

import SwiftUI
import AVFoundation
import RealmSwift

struct PlayWord: View {
    var wordObjectID: String
    var givenWord : String
    @State var beingPlayed: Bool = false
    
    var body: some View {
        Button {
            didPressSpeakButton()
        } label: {
            if !beingPlayed{
                Image("play_navy")
                    .resizable()
                    .frame(width: 50, height: 50)
            } else {
                Image("stop")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .disabled(beingPlayed)
    }
}
// Play Button -> pass the texts or a text


extension PlayWord{
    func didPressSpeakButton() {
        // Disable the "Speak" button while processing/speaking
        beingPlayed.toggle()
        // Run the speech service
        SpeechService.shared.speak(text: self.givenWord) {
            // Re-enable the "Speak" button now that the speech service finished
            beingPlayed.toggle()
        }
        
        // It currently does not update the playTimes on a regular basis (too much?
        DispatchQueue.main.async {
        let realm = try! Realm()
            let wordObject = realm.object(ofType: WordRealm.self, forPrimaryKey: self.wordObjectID)!
            try! realm.write {
                wordObject.playedTimes += 1
            }
        }
    }
}

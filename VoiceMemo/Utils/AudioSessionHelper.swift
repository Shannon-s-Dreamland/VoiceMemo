//
//  AudioSessionHelper.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import AVFoundation

class AudioSessionHelper {
    
    class func setupSessionActive(active: Bool, catagory: String = AVAudioSessionCategoryPlayback) {
        let session = AVAudioSession.sharedInstance()
        if active {
            do {
                try session.setCategory(catagory)
            } catch {
                assertionFailure()
            }
            
            do {
                try session.setActive(true)
            } catch {
                assertionFailure()
            }
        } else {
            do {
                try session.setActive(false, withOptions: .NotifyOthersOnDeactivation)
            } catch {
                assertionFailure()
            }
        }
    }
}

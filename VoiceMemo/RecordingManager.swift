//
//  RecordingManager.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - RecordingManagerDelegate

protocol RecordingManagerDelegate: class {
    func updateRecordedTimeInterval(duration: NSTimeInterval)
    func handleRecordingInterrupted()
    func hanldePermissionError()
    func handleRecorderFetchError()
    func handleRecorderEncodingError()
    func handleVoiceSaveError()
}

// MARK: - RecordingError

enum RecordingError: ErrorType {
    case AudioExist
    case RecorderNotExist
}

// MARK: RecordingState

enum RecordingState {
    case Initial
    case Finished
}

// MARK: - RecordingManager

class RecordingManager:NSObject, AVAudioRecorderDelegate {
    // MARK: Properties

    weak var delegate: RecordingManagerDelegate?
    var audioDuration: NSTimeInterval {
        return recordDuration
    }
    private var state  = RecordingState.Initial
    private var audioRecorder: AVAudioRecorder?
    private var recordTimer: NSTimer? {
        willSet {
            if newValue == nil {
                recordTimer?.invalidate()
            }
        }
    }
    private var recordDuration: NSTimeInterval = 0
    let tmpStoreURL = NSURL.fileURLWithPath(NSTemporaryDirectory()).URLByAppendingPathComponent("tmpVoice.caf")
        
    // MARK: Initializers
    init(delegate: RecordingManagerDelegate?) {
        super.init()
        
        self.delegate = delegate
        prepareForRecording()
    }

    // MARK: Recording Management

    func startNewRecording() throws {
        guard let recorder = self.audioRecorder else { throw RecordingError.RecorderNotExist }
        guard state != .Finished else { throw RecordingError.AudioExist }
        
        AudioSessionHelper.setupSessionActive(true, catagory: AVAudioSessionCategoryRecord)
        if recorder.prepareToRecord() {
            debugPrint("Start recording")
            
            audioRecorder?.record()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleInterruption:", name: AVAudioSessionInterruptionNotification, object: AVAudioSession.sharedInstance())
            
            self.recordTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                target: self,
                selector: "updateDuration",
                userInfo: nil,
                repeats: true)
        }
    }
 
    func finishRecording() {
        recordTimer = nil
        state = .Finished
        recordDuration = audioRecorder?.currentTime ?? 0
        audioRecorder?.stop()
        AudioSessionHelper.setupSessionActive(false)
    }
    
    func deleteRecordedAudio() {
        state = .Initial
    }
    
    func saveRecordedAudioWithName(name: String?) {
        do {
            let voiceName = (name ?? NSLocalizedString("未命名", comment: "")) + " " + NSUUID().UUIDString
            
            let voice: Voice = try CoreDataStack.createNewObject()
            voice.date = NSDate()
            voice.duration = recordDuration
            voice.name = voiceName
            
            var storeURL = try FileHandler.getDirectoryURL()
            storeURL = storeURL.URLByAppendingPathComponent(voiceName)
            try NSFileManager.defaultManager().moveItemAtURL(tmpStoreURL, toURL: storeURL)
            CoreDataStack.save()
        } catch let error {
            debugPrint(error)
            delegate?.handleVoiceSaveError()
        }
        
        state = .Initial
    }
    
    // MARK: Convience

    private func prepareForRecording() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            if granted {
                debugPrint("Recording permission has been granted")
                
                let recordSettings: [String : AnyObject]  = [
                    AVFormatIDKey : NSNumber(unsignedInt: kAudioFormatLinearPCM),
                    AVSampleRateKey : 44100.0,
                    AVNumberOfChannelsKey : 2,
                    AVLinearPCMBitDepthKey : 16,
                    AVLinearPCMIsBigEndianKey : false,
                    AVLinearPCMIsFloatKey : false,
                ]
                
                do {
                    self.audioRecorder = try AVAudioRecorder(URL: self.tmpStoreURL, settings: recordSettings)
                    self.audioRecorder?.delegate = self
                } catch {
                    self.delegate?.handleRecorderFetchError()
                }
            } else {
                debugPrint("Recording permission has not been granted")
                
                self.delegate?.hanldePermissionError()
            }
        }
    }
    
    private func handleInterruption(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let interruptionType = userInfo[AVAudioSessionInterruptionTypeKey] as! UInt
            if interruptionType == AVAudioSessionInterruptionType.Began.rawValue {
                recordTimer = nil
                if audioRecorder?.recording == true {
                    audioRecorder?.stop()
                    audioRecorder?.deleteRecording()
                    state = .Initial
                }
            } else if interruptionType == AVAudioSessionInterruptionType.Ended.rawValue {
                delegate?.handleRecordingInterrupted()
            }
        }
    }
    
    //MARK: RecordingManagerDelegate
    
    func updateDuration() {
        if let duration = audioRecorder?.currentTime {
            delegate?.updateRecordedTimeInterval(duration)
        }
    }
    
    // MARK: AVAudioRecorderDelegate
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        assertionFailure()
        
        delegate?.handleRecorderEncodingError()
    }

}

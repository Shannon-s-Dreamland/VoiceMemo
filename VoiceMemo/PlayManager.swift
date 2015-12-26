//
//  AudioPlayer.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - PlayManagerDelegate

protocol PlayManagerDelegate: class {
    func updatePlayStatusWithCurrentTime(currentTime: NSTimeInterval, totalTime: NSTimeInterval)
    func playerDidChangeToState(state: PlaybackState)
    func handlePlaybackError()
}

// MARK: - Playback State

enum PlaybackState {
    case Initial
    case Play
    case Pause
}

// MARK: - Play Manager

class PlayManager: NSObject {
    
    // MARK: Properties

    private var player: AVAudioPlayer?
    
    private var playTimer: NSTimer? {
        willSet {
            if newValue == nil {
                playTimer?.invalidate()
            }
        }
    }
    
    private var state: PlaybackState = .Initial {
        didSet {
            switch state {
            case .Initial:
                player = nil
                playTimer = nil
                currentItem = nil
                temporaryItem = nil
                AudioSessionHelper.setupSessionActive(false)
            case .Play:
                playTimer = nil
                playTimer = NSTimer(
                    timeInterval: 0.1,
                    target: self,
                    selector: "updateProgress",
                    userInfo: nil,
                    repeats: true)
                NSRunLoop.currentRunLoop().addTimer(playTimer!, forMode: NSRunLoopCommonModes)

                if player != nil {
                    player?.play()
                    return
                }
                
                do {
                    let url: NSURL
                    if let currentItem = currentItem {
                        url = try FileHandler.getDirectoryURL().URLByAppendingPathComponent(currentItem)
                    } else if let temporaryItem = temporaryItem {
                        url = temporaryItem
                    } else {
                        assertionFailure()
                        return
                    }
                    
                    try player = AVAudioPlayer(contentsOfURL: url)
                    player?.delegate = self
                    
                    AudioSessionHelper.setupSessionActive(true)
                    player?.play()
                } catch {
                    state = .Initial
                    delegate?.handlePlaybackError()
                }
            case .Pause:
                playTimer = nil
                player?.pause()
                AudioSessionHelper.setupSessionActive(false)
            }
            delegate?.playerDidChangeToState(state)
        }
    }

    private var currentItem: String? {
        didSet {
            if currentItem == nil { return }
            state = .Play
        }
    }
    
    private var temporaryItem: NSURL? {
        didSet {
            if temporaryItem == nil { return }
            state = .Play
        }
    }
    
    weak var delegate: PlayManagerDelegate?
    
    // MARK: Initializers
    
    init(delegate: PlayManagerDelegate?) {
        super.init()
        
        self.delegate = delegate
    }
    
    // MARK: Convience

    func playItem(item: String) {
        state = .Initial
        
        currentItem = item
    }
    
    func playTemporaryItem(item: NSURL) {
        state = .Initial
        
        temporaryItem = item
    }
    
    func play() {
        state = .Play
    }
    
    func pause() {
        state = .Pause
    }
    
    func stop() {
        state = .Initial
    }
    
    func playingVoice(voice: Voice) -> Bool {
        return voice.name == currentItem
    }
    
    func togglePlayState() {
        if state == .Play {
            state = .Pause
        } else if state == .Pause {
            state = .Play
        }
    }
    
    func updateProgress() {
        if let currentTime = player?.currentTime,
            totalTime = player?.duration {
                delegate?.updatePlayStatusWithCurrentTime(currentTime, totalTime: totalTime)
        }
    }
    
}

// MARK: - AVAudioPlayerDelegate

extension PlayManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            state = .Initial
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        debugPrint(error)
        
        delegate?.handlePlaybackError()
    }
    
}

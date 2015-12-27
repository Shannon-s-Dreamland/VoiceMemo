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
    case Finished
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
            case .Initial,
                 .Finished:
                player = nil
                playTimer = nil
                currentItem = nil
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
                    guard currentItem != nil else {
                        assertionFailure()
                        state = .Initial
                        return
                    }
                    try player = AVAudioPlayer(contentsOfURL: currentItem!)
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

    private var currentItem: NSURL? {
        didSet {
            guard currentItem != nil else { return }
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

    func playItem(item: NSURL) {
        state = .Initial
        
        currentItem = item
    }
    
    func stop() {
        state = .Initial
    }
    
    func playingVoice(voice: Voice) -> Bool {
        return voice.name == currentItem?.lastPathComponent
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
            state = .Finished
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        debugPrint(error)
        
        delegate?.handlePlaybackError()
    }
    
}

//
//  ViewController.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/25/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController, SegueHandlerType {

    // MARK: IBOutlet
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        state = .Initial
    }

    
    // MARK: Segue
    
    enum SegueIdentifier: String {
        case ShowVoiceList
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segueIdentifierForSegue(segue)
        
        switch segueIdentifier {
        case .ShowVoiceList:()
            // TODO: 添加录音播放播放和录制状态提醒
        }
    }
    
    // MARK: State Change
    
    enum RecordingState {
        case Initial
        case Recording
        case RecordingFinished
        case Playing
        case PlayPaused
    }

    var state: RecordingState = .Initial {
        didSet {
            switch state {
            case .Initial:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                recordButton.enabled = true
                recordButton.setImage(UIImage(named: "record_begin"), forState: .Normal)
                saveButton.enabled = true
                timeLabel.text = NSLocalizedString("长按录音键开始录音", comment: "")
            case .Recording:
                playButton.enabled = false
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                recordButton.enabled = true
                recordButton.setImage(UIImage(named: "record_pause"), forState: .Normal)
                saveButton.enabled = false
                timeLabel.text = NSLocalizedString("放开录音键停止录音", comment: "")
            case .RecordingFinished:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                recordButton.enabled = true
                recordButton.setImage(UIImage(named: "record_begin"), forState: .Normal)
                saveButton.enabled = true
                timeLabel.text = NSLocalizedString("\(audioDuration)", comment: "")
            case .Playing:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_pause"), forState: .Normal)
                recordButton.enabled = false
                recordButton.setImage(UIImage(named: "record_begin"), forState: .Normal)
                saveButton.enabled = false
            case .PlayPaused:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                recordButton.enabled = true
                recordButton.setImage(UIImage(named: "record_begin"), forState: .Normal)
                saveButton.enabled = true
            }
        }
    }

    
    // MARK: Audio Recorder
    
    var audioDuration: NSTimeInterval {
        return 0.0
    }


}


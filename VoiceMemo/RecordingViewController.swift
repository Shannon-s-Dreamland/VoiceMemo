//
//  ViewController.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/25/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController, SegueHandlerType, TextFieldAlertDelegate {

    // MARK: Properties
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    lazy var recordingManager: RecordingManager = {
        let recordingManager = RecordingManager(delegate: self)
        return recordingManager
    }()

    var audioURL: NSURL?
    
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
                playButton.enabled = false
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                saveButton.enabled = false
                saveButton.alpha = 0.8
                timeLabel.text = NSLocalizedString("长按录音键开始录音", comment: "")
                audioURL = nil
            case .Recording:
                playButton.enabled = false
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                saveButton.enabled = false
                saveButton.alpha = 0.8
                timeLabel.text = NSLocalizedString("放开录音键停止录音", comment: "")
            case .RecordingFinished:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                saveButton.enabled = true
                saveButton.alpha = 1.0
                updateRecordedTimeInterval(recordingManager.audioDuration)
                audioURL = recordingManager.tmpStoreURL
            case .Playing:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_pause"), forState: .Normal)
                saveButton.enabled = false
            case .PlayPaused:
                playButton.enabled = true
                playButton.setImage(UIImage(named: "play_begin"), forState: .Normal)
                saveButton.enabled = true
                saveButton.alpha = 1.0
            }
        }
    }

    @IBAction func playAudio(sender: UIButton) {
        
    }
    
    @IBAction func saveAudio(sender: UIButton) {
        save()
    }
    
    func save() {
        Alert.showInputAlertWithSourceViewController(self, title: NSLocalizedString("标题", comment: ""), message: NSLocalizedString("请输入当前备忘录标题", comment: ""), confirmTitle: "保存", delegate: self)
    }
    
    func inputFinishedWithContent(content: String?) {
        recordingManager.saveRecordedAudioWithName(content)
        state = .Initial
    }
    
    @IBAction func recordAudio(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            do {
                try recordingManager.startNewRecording()
                state = .Recording
            } catch RecordingError.AudioExist {
                let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
                    self.state = .RecordingFinished
                })
                let delete: AlertActionTuple = (title: NSLocalizedString("删除旧的音频备忘录", comment: ""), style: .Destructive, { action in
                    self.recordingManager.deleteRecordedAudio()
                    self.state = .Initial
                })
                let save: AlertActionTuple = (title: NSLocalizedString("保存音频备忘录", comment: ""), style: .Default, { action in
                    self.save()
                    self.state = .Initial
                })
                Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("您已经录制了一个音频备忘录, 请保存旧的备忘录或者删除当前音频备忘录再进行新的录制", comment: ""), message: nil, actionTuples: [cancel, delete, save])
            } catch let error {
                debugPrint("\(error)")
                handleRecordingInterrupted()
            }
        case .Ended:
            state = .RecordingFinished
            recordingManager.finishRecording()
        default:()
        }
    }
    
}

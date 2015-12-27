//
//  ViewController.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/25/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController, SegueHandlerType, TextFieldAlertDelegate, PlayManagerDelegate {

    // MARK: Properties
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    lazy var recordingManager: RecordingManager = {
        let recordingManager = RecordingManager(delegate: self)
        return recordingManager
    }()
    
    lazy var playManager: PlayManager = {
        let playManager = PlayManager(delegate: self)
        return playManager
    }()

    var audioURL: NSURL?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        state = .Initial
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        playManager.delegate = self
    }
    
    // MARK: Segue
    
    enum SegueIdentifier: String {
        case ShowVoiceList
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.ShowVoiceList.rawValue {
            switch state {
            case .Initial:
                return true
            default:
                let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
                })
                let delete: AlertActionTuple = (title: NSLocalizedString("删除当前音频备忘录", comment: ""), style: .Destructive, { action in
                    self.recordingManager.deleteRecordedAudio()
                    self.state = .Initial
                    self.performSegueWithIdentifier(.ShowVoiceList, sender: self)
                })
                let save: AlertActionTuple = (title: NSLocalizedString("保存当前音频备忘录", comment: ""), style: .Default, { action in
                    self.save()
                    self.state = .Initial
                    self.performSegueWithIdentifier(.ShowVoiceList, sender: self)
                })
                Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("您已经录制了一个音频备忘录, 请选择如何处理当前备忘录", comment: ""), message: nil, actionTuples: [cancel, delete, save])
                return false
            }
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segueIdentifierForSegue(segue)
        
        switch segueIdentifier {
        case .ShowVoiceList:
            if let destinationVC = segue.destinationViewController as? VoiceListViewController {
                destinationVC.playManager = playManager
            }
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
                audioURL = recordingManager.tmpStoreURL
                timeLabel.text = NSLocalizedString("点击播放按钮播放, 或者点击保存按钮保存", comment: "")
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
        if state == .Playing {
            playManager.togglePlayState()
            state = .PlayPaused
        } else if state == .PlayPaused {
            playManager.togglePlayState()
            state = .Playing
        } else {
            if let URL = audioURL {
                playManager.playItem(URL)
                state = .Playing
            } else {
                assertionFailure()
            }
            state = .Playing
        }
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

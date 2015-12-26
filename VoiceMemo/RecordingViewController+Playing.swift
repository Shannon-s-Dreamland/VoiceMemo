//
//  RecordingViewController+Playing.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation

extension RecordingViewController {
    func updatePlayStatusWithCurrentTime(currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        timeLabel.text = currentTime.format(2) + "s/" + totalTime.format(2) + "s"
    }
    
    func playerDidChangeToState(state: PlaybackState) {
        switch state {
        case .Initial:
            self.state = .RecordingFinished
        case .Pause,
        .Play:()
        }
    }
    
    func handlePlaybackError() {
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            self.state = .RecordingFinished
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("播放错误, 请重试", comment: ""), message: nil, actionTuples: [cancel])
    }

}

//
//  RecordingViewController+ErrorHandling.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

extension RecordingViewController: RecordingManagerDelegate {
    
    func updateRecordedTimeInterval(duration: NSTimeInterval) {
        timeLabel.text = duration.format(0) + " s"
    }
    
    func handleRecordingInterrupted() {
        self.state = .Initial
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            //
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("录制过程发生中断, 请重新录制", comment: ""), message: nil, actionTuples: [cancel])
        
    }
    
    func hanldePermissionError() {
        self.state = .Initial
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            //
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("无法访问您设备的音频, 请在个人隐私中开启", comment: ""), message: nil, actionTuples: [cancel])
    }
    
    func handleRecorderFetchError() {
        self.state = .Initial
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            //
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("当前无法进行音频录制, 请稍后重试", comment: ""), message: nil, actionTuples: [cancel])
    }
    
    func handleRecorderEncodingError() {
        self.state = .Initial
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            //
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("音频编码失败, 请稍后重试", comment: ""), message: nil, actionTuples: [cancel])
    }
    
    func handleVoiceSaveError() {
        self.state = .RecordingFinished
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            //
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("文件保存失败, 请尝试重新命名", comment: ""), message: nil, actionTuples: [cancel])
    }
}
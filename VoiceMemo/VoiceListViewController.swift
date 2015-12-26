//
//  VoiceListViewController.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/25/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit
import CoreData

// MARK: - VoiceListCell

class VoiceListCell: UITableViewCell {
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    func configureCellWithVoice(voice: Voice) {
        titleLabel.text = voice.name.segmentsWithSeparator().first!
        dateLabel.text = voice.date.stringValue
        durationLabel.text = voice.duration.format(2) + " s"
        progressView.progress = 0.0
    }
}

// MARK: - VoiceListViewController

class VoiceListViewController: UITableViewController {
    // MARK: Properties
    var fetchedResultsController : NSFetchedResultsController!
    var playManager: PlayManager? {
        didSet {
            playManager?.delegate = self
        }
    }
    var currentVoice: Voice?
    var playingCell: VoiceListCell? {
        willSet {
            if newValue == nil {
                assertionFailure("不应该为空 Cell")
            }
        }
        didSet {
            if playingCell == oldValue {
                playManager?.togglePlayState()
                return
            }
            
            oldValue?.progressView.hidden = true
            playingCell?.progressView.hidden = false
            
            if let cell = playingCell,
                indexPath = tableView.indexPathForCell(cell) {
                let voice = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
                playManager?.playItem(voice.name)
            }
        }
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Voice")
        fetchRequest.fetchBatchSize = 20
        let keySort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [keySort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            debugPrint("无法获取数据库数据: \(error)")
        }

        tableView.estimatedRowHeight = 100.0
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Convience
    
    func deleteVoice(voice: Voice) {
        playManager?.stop()
        
        do {
            let removeFileURL = try FileHandler.getDirectoryURL().URLByAppendingPathComponent(voice.name)
            try NSFileManager.defaultManager().removeItemAtURL(removeFileURL)
            CoreDataStack.context.deleteObject(voice)
            CoreDataStack.save()
        } catch let error {
            assertionFailure("\(error)")
        }
    }


}

// MARK: UITableViewDataSource

extension VoiceListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("Cell") as! VoiceListCell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let voice = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
            deleteVoice(voice)
        default:
            break
        }
    }
    
}

// MARK: UITableViewDelegate

extension VoiceListViewController {
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let voice = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
        (cell as! VoiceListCell).configureCellWithVoice(voice)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        playingCell = tableView.cellForRowAtIndexPath(indexPath) as? VoiceListCell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}


// MARK: NSFetchedResultsControllerDelegate

extension VoiceListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert,
                 .Update,
                 .Move:
                assertionFailure("没有实现这些操作")
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            }
            
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}

extension VoiceListViewController: PlayManagerDelegate {
    func updatePlayStatusWithCurrentTime(currentTime: NSTimeInterval, totalTime: NSTimeInterval) {
        let progress = currentTime / totalTime
        if let cell = playingCell {
            cell.progressView.progress = CGFloat(progress)
        } else {
            assertionFailure()
        }
    }
    
    func playerDidChangeToState(state: PlaybackState) {
        if let cell = playingCell {
            switch state {
            case .Play:
                cell.progressView.iconStyle = .Pause
            case .Pause:
                cell.progressView.iconStyle = .Play
            case .Initial:
                cell.progressView.iconStyle = .Play
            }
        } else {
            assertionFailure()
        }
    }
    
    func handlePlaybackError() {
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("播放错误, 请重试", comment: ""), message: nil, actionTuples: [cancel])
    }
}

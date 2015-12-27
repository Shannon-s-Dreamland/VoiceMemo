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

enum VoiceListCellState {
    case NotCurrent
    case Current
}

class VoiceListCell: UITableViewCell {
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var state = VoiceListCellState.NotCurrent {
        didSet {
            switch state {
            case .NotCurrent:
                progressView.progress = 0
                progressView.iconStyle = .Play
            case .Current:()
            }
        }
    }
    
    func configureCellWithVoice(voice: Voice) {
        titleLabel.text = voice.name.segmentsWithSeparator().first!
        dateLabel.text = voice.date.stringValue
        durationLabel.text = voice.duration.format(2) + " s"
    }
    
    override func prepareForReuse() {
        state = .NotCurrent
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
    var currentCell: VoiceListCell? {
        if let indexPath = playingIndexpath,
            cell = tableView.cellForRowAtIndexPath(indexPath) as? VoiceListCell {
                return cell
        }
        return nil
    }
    var shouldRestorePlayingIndexpath = false
    var previousPlayingIndexpath: NSIndexPath?
    var previousVell: VoiceListCell? {
        if let indexPath = previousPlayingIndexpath,
            cell = tableView.cellForRowAtIndexPath(indexPath) as? VoiceListCell {
                return cell
        }
        return nil
    }
    
    var playingIndexpath: NSIndexPath? {
        didSet {
            if playingIndexpath == oldValue {
                if let cell = tableView.cellForRowAtIndexPath(playingIndexpath!) as? VoiceListCell {
                    if cell.progressView.iconStyle == .Play {
                        cell.progressView.iconStyle = .Pause
                    } else {
                        cell.progressView.iconStyle = .Play
                    }
                    
                    playManager?.togglePlayState()
                    return
                }
            }
            
            if previousPlayingIndexpath != nil && playingIndexpath != nil {
                previousVell?.state = .NotCurrent
            }
            if let indexPath = playingIndexpath,
                cell = tableView.cellForRowAtIndexPath(indexPath) as? VoiceListCell {
                    let voice = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Voice
                    cell.state = .Current
                    if let URL = voice.fetchPathURL() {
                        playManager?.playItem(URL)
                    } else {
                        assertionFailure()
                    }
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

    func restoreCell(cell: VoiceListCell) {
        cell.progressView.progress = 1.0
        cell.progressView.iconStyle = .Play
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
        
        if indexPath == previousPlayingIndexpath && shouldRestorePlayingIndexpath {
            restoreCell(cell as! VoiceListCell)
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == previousPlayingIndexpath {
            shouldRestorePlayingIndexpath = true
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        playingIndexpath = indexPath
        previousPlayingIndexpath = nil
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
        currentCell?.progressView.progress = CGFloat(progress)
    }
    
    func playerDidChangeToState(state: PlaybackState) {
        switch state {
        case .Play:
            currentCell?.progressView.iconStyle = .Pause
        case .Initial,
             .Pause:
            currentCell?.progressView.iconStyle = .Play
        case .Finished:
            if currentCell == nil {
                shouldRestorePlayingIndexpath = true
            } else {
                currentCell?.progressView.progress = 1.0
                currentCell?.progressView.iconStyle = .Play
                shouldRestorePlayingIndexpath = false
            }
            previousPlayingIndexpath = playingIndexpath
            playingIndexpath = nil
        }
    }
    
    func handlePlaybackError() {
        let cancel: AlertActionTuple = (title: NSLocalizedString("返回", comment: ""), style: .Cancel, { action in
            
        })
        Alert.showAlertWithSourceViewController(self, title: NSLocalizedString("播放错误, 请重试", comment: ""), message: nil, actionTuples: [cancel])
    }
}

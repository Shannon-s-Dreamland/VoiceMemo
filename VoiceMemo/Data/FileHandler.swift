//
//  AudioFileHandler.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation

enum FileHandlerError: ErrorType {
    case DirectoryCreationError
}

struct FileHandler {
    static func getDirectoryURL() throws -> NSURL {
        let doucumentURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        let directoryURL = doucumentURL.URLByAppendingPathComponent("Voice")
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            debugPrint("无法创建磁盘目录: \(error)")
            throw FileHandlerError.DirectoryCreationError
        }
        return directoryURL
    }

}

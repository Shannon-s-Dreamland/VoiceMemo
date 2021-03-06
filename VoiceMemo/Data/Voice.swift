//
//  Voice+CoreDataProperties.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

class Voice: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var duration: Double

    
    func fetchPathURL() -> NSURL? {
        do {
            let URL = try FileHandler.getDirectoryURL().URLByAppendingPathComponent(name)
            return URL
        } catch {
            assertionFailure()
            return nil
        }
    }
}

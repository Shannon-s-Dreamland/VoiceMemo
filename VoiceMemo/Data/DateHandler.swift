//
//  DateHandler.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation

extension NSDate {
    var stringValue: String {
        let dateFormatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            return formatter
        }()
        
        return dateFormatter.stringFromDate(self)
    }
}
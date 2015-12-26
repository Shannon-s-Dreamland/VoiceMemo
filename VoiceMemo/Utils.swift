//
//  Utils.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import Foundation

extension Double {
    func format(f: Int) -> String {
        return NSString(format: "%.\(f)f", self) as String
    }
}

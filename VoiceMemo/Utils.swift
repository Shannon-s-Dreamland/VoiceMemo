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

extension String {
    /**
     将 String 用指定的 Separator 切割成 String 数组
     
     - parameter separator: 要用的 Separator, 默认为空格
     
     - returns: 一个切割好的 String 数组
     */
    func segmentsWithSeparator(separator: Character = " ") -> [String] {
        return self.characters.split(separator).map(String.init)
    }
}
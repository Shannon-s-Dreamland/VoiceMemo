//
//  File.swift
//  Client
//
//  Created by Shannon Wu on 10/25/15.
//  Copyright © 2015 36Kr. All rights reserved.
//

#if os(iOS)
    import UIKit
    /// StoryboardSegue 是 UIStoryboardSegue 的别名
    typealias StoryboardSegue = UIStoryboardSegue
    /// ViewController 是 UIViewController 的别名
    typealias ViewController = UIViewController
#elseif os(OSX)
    import Cocoa
    /// StoryboardSegue 是 NSStoryboardSegue 的别名
    typealias StoryboardSegue = NSStoryboardSegue
    /// ViewController 是 NSWindowController 的别名
    typealias ViewController = NSWindowController
#endif

/**
 *  添加 `SegueHandlerType` 协议, 只有 `ViewController` 才可以继承这个协议, 并且限定 
    `SegueIdentifier` 属性的 `RawValue` 必须是 `String` 类型
 */
protocol SegueHandlerType {

    typealias SegueIdentifier: RawRepresentable

}

// MARK: - 添加 `SegueHandlerType` 协议, 只有 `ViewController` 才可以继承这个
//         协议,并且限定 `SegueIdentifier` 属性的 `RawValue` 必须是 `String` 类型
extension SegueHandlerType where Self: ViewController, SegueIdentifier.RawValue == String {
    
    /**
     覆写 `UIViewController` 的 `performSegueWithIdentifier(_:sender:)` 方法, 
     但是接受的数据类型是 `segueIdentifier` 枚举类型, 而不是 `String` 类型
     
     - parameter segueIdentifier: 触发 `Segue` 的 `SegueIdentifier`
     - parameter sender:          触发 `Segue` 的发送者
     */
    func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(segueIdentifier.rawValue, sender: sender)
    }

    /**
     通过 `Segue` 实例获取 `SegueIdentifier` 的 enum 实例, 如果 SegueIdentifier 中没有 enum 实例,
     说明发生错误, 触发 fatalError
     
     - parameter segue: 要获取 `SegueIdentifier` 的 `Segue` 实例
     
     - returns: `SegueIdentifier` 的一个 enum 实例, 或者触发 fatalError
     */
    func segueIdentifierForSegue(segue: StoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            segueIdentifier = SegueIdentifier(rawValue: identifier) else {
                fatalError("在 \(self.dynamicType) 中, 无法通过 \(segue.identifier) 获取 SegueIdentifier 实例.")
        }

        return segueIdentifier
    }

}

//
//  AppDelegate.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/25/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        CoreDataStack.save()
    }
    
}

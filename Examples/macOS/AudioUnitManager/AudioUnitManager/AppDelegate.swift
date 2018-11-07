//
//  AppDelegate.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        NotificationCenter.default.post(name: Notification.Name("AudioUnitManager.handleApplicationInit"), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

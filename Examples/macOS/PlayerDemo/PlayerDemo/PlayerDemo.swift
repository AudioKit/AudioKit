//
//  AppDelegate.swift
//  PlayerDemo
//
//  Created by Ryan Francesconi on 7/26/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import Cocoa

@NSApplicationMain
class PlayerDemo: NSObject, NSApplicationDelegate {
    var windowController = PlayerDemoWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        windowController.window?.delegate = self
        windowController.window?.center()
        windowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }
}

extension PlayerDemo: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        exit(0)
    }
}

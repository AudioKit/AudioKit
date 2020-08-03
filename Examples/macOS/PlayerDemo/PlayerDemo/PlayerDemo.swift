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

    public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }
}

extension PlayerDemo: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        windowController.controller.terminate()
    }
}

class PlayerDemoWindowController: NSWindowController {
    var controller = PlayerDemoViewController()

    convenience init() {
        self.init(windowNibName: "PlayerDemoWindowController")
        window?.appearance = NSAppearance(named: .vibrantDark)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        contentViewController = controller
    }
}

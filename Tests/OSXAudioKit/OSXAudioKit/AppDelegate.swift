//
//  AppDelegate.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        AKManager.sharedManager.setupAudioUnit()
        _ = AKPhasorTester()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}


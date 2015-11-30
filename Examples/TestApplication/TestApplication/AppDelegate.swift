//
//  AppDelegate.swift
//  TestApplication
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Cocoa
import AudioKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let audiokit = AKManager.sharedInstance

    let input = AKMicrophone()
    var delay:  AKDelay?
    var distortion: AKDistortion?
    var jcReverb: AKChowningReverb?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        delay = AKDelay(input)
        distortion = AKDistortion(delay!)
        jcReverb = AKChowningReverb(distortion!)
        audiokit.audioOutput = jcReverb
        audiokit.start()

    }

}


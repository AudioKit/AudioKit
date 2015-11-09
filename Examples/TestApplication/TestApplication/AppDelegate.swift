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
    var delay:  AKAUDelay?
    var distortion: AKAUDistortion?
    var jcReverb: AKChowningReverb?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        delay = AKAUDelay(input)
        distortion = AKAUDistortion(delay!)
        jcReverb = AKChowningReverb(distortion!)
        audiokit.audioOutput = jcReverb
        audiokit.start()

    }

}


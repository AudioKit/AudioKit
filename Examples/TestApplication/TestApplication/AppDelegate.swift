//
//  AppDelegate.swift
//  TestApplication
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Cocoa
import AVFoundation
import AudioKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var engine = AVAudioEngine()
    var delay = AVAudioUnitDelay()
    var effect = AVAudioUnit()


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        
        AUAudioUnit.registerSubclass(
            AKMoogLadderAudioUnit.self,
            asComponentDescription: componentDescription,
            name: "Local AKMoogLadder",
            version: UInt32.max)
        
        AVAudioUnit.instantiateWithComponentDescription(componentDescription, options: []) { avAudioUnit, error in
            guard let avAudioUnitEffect = avAudioUnit else { return }
            
            self.effect = avAudioUnitEffect
            self.engine.attachNode(avAudioUnitEffect)
        }
        
        // Setup engine and node instances
        let input  = engine.inputNode
        let output = engine.outputNode

        engine.attachNode(delay)

        // Connect nodes
        engine.connect(input!, to: delay,  format: nil)
        engine.connect(delay,  to: effect, format: nil)
        engine.connect(effect, to: output, format: nil)
        
        // Start the engine.
        do {
            try self.engine.start()
        }
        catch {
            fatalError("Could not start engine. error: \(error).")
        }

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}


//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 9/29/15.
//
//

import UIKit
import AVFoundation
import AudioKit

class ViewController: UIViewController {
    
    var engine = AVAudioEngine()
    var delay = AVAudioUnitDelay()
    var distortion = AVAudioUnitDistortion()
    var reverb = AVAudioUnitReverb()
    var effect = AVAudioUnit()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let input = engine.inputNode
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
}


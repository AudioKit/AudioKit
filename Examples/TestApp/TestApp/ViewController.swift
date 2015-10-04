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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup engine and node instances
        let input = engine.inputNode
        let output = engine.outputNode
        
        let moog = AKMoogLadder()
        moog.setup()
        engine.attachNode(moog.effect!)
        
        engine.attachNode(delay)
    
        // Connect nodes
        engine.connect(input!, to: delay,  format: nil)
        engine.connect(delay,  to: moog.effect!, format: nil)
        engine.connect(moog.effect!, to: output, format: nil)
        
        // Start the engine.
        do {
            try self.engine.start()
        }
        catch {
            fatalError("Could not start engine. error: \(error).")
        }
    }
}


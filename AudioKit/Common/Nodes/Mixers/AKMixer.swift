//
//  AKMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/19/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Mixer Node */
public class AKMixer: AKNode {
    private let mixerAU = AVAudioMixerNode()
    
    /** Output Volume (Default 1) */
    public var volume: Float = 1.0 {
        didSet {
            if volume < 0 {
                volume = 0
            }
            mixerAU.outputVolume = volume
        }
    }
    
    /** Initialize the delay node */
    public init(_ inputs: AKNode...) {
        super.init()
        output = mixerAU
        AKManager.sharedInstance.engine.attachNode(output!)
        for input in inputs {
            connect(input)
        }
    }
    
    public func connect(input: AKNode) {
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
}

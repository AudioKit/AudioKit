//
//  AKSplitter.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/12/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Splitter Audio Unit */
public class AKSplitter: AKNode {
    
    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_FormatConverter,
        componentSubType: kAudioUnitSubType_MultiSplitter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)
    
    public var internalEffect = AVAudioUnit()
    public var internalAU = AudioUnit()
    

    /** Initialize the splitter  node */
    public init(_ input: AKNode) {

            super.init()
            
            AVAudioUnit.instantiateWithComponentDescription(cd, options: []) {
                avAudioUnit, error in
//                guard let avAudioUnit = avAudioUnit else { return }
//
//                self.output = avAudioUnit
//                self.internalAU = avAudioUnit.audioUnit
//                AKManager.sharedInstance.engine.attachNode(self.output!)
//                AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: AKManager.format)
            }
    }
}

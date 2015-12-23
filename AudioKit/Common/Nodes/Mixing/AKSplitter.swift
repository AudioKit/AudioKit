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
public struct AKSplitter: AKNode {
    
    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Mixer,
        componentSubType: kAudioUnitSubType_MultiSplitter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)
    
    public var internalEffect = AVAudioUnit()
    public var internalAU = AudioUnit()
    public var avAudioNode: AVAudioNode
    
    
    /** Initialize the splitter  node */
    public init(_ input: AKNode) {
        
        self.avAudioNode = AVAudioNode()
        AVAudioUnit.instantiateWithComponentDescription(cd, options: []) {
            avAudioUnit, error in
            guard let avAudioUnit = avAudioUnit else { return }
            
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.audioUnit
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
        }
    }
}

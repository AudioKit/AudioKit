//
//  AKNode.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/2/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** Parent class for all AudioKit Nodes */
public class AKNode {
    
    /** Output of the node */
    public var output: AVAudioNode?
    
    /** AVAudioUnit */
    public var avUnit: AVAudioUnit?
    
    /** Required initialization method */
    init() {
        // Override in subclass
    }

    public static func effect(input: AKNode, operation: AKOperation) -> AKOperationEffect {
        // add "dup" to copy the left channel output to the right channel output
        return AKOperationEffect(input, sporth:"\(operation) dup")
    }
    public static func effect(input: AKNode, operation: AKStereoOperation) -> AKOperationEffect {
        return AKOperationEffect(input, sporth:"\(operation) swap")
    }
    
    public static func stereoEffect(input: AKNode, leftOperation: AKOperation, rightOperation: AKOperation) -> AKOperationEffect {
        return AKOperationEffect(input, sporth:"\(leftOperation) swap \(rightOperation) swap")
    }
    
    public static func generator(operation: AKOperation, triggered: Bool = false) -> AKOperationGenerator {
        return AKOperationGenerator("\(operation) dup", triggered: triggered)
    }
    
    public static func generator(operation: AKStereoOperation, triggered: Bool = false) -> AKOperationGenerator {
        return AKOperationGenerator("\(operation) swap", triggered: triggered)
    }
    
    public static func generator(left: AKOperation, _ right: AKOperation, triggered: Bool = false) -> AKOperationGenerator {
        return AKOperationGenerator("\(left) \(right)", triggered: triggered)
    }
}

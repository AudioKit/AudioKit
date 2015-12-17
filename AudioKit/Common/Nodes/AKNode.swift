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
    
    /** Required initialization method */
    init() {
        // Override in subclass
    }

    public static func effect(input: AKNode, operation: AKOperation) -> AKCustomEffect {
        // Add "swap drop" to discard the right channel input, and then
        // add "dup" to copy the left channel output to the right channel output
        return AKCustomEffect(input, sporth:"\(operation) swap drop dup")
    }
    public static func effect(input: AKNode, operation: AKStereoOperation) -> AKCustomEffect {
        return AKCustomEffect(input, sporth:"\(operation)")
    }
    
    public static func stereoEffect(input: AKNode, leftOperation: AKOperation, rightOperation: AKOperation) -> AKCustomEffect {
        return AKCustomEffect(input, sporth:"\(leftOperation) swap \(rightOperation) swap")
    }
    
    public static func generator(operation: AKOperation) -> AKCustomGenerator {
        return AKCustomGenerator("\(operation) dup")
    }
    
    public static func generator(left: AKOperation, _ right: AKOperation) -> AKCustomGenerator {
        return AKCustomGenerator("\(left) \(right)")
    }
}

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

    public static func effect(input: AKNode, operation: AKParameter) -> AKCustomEffect {
        // Add "swap drop" to discard the right channel input, and then
        // add "dup" to copy the left channel output to the right channel output
        return AKCustomEffect(input, sporth:"\(operation) swap drop dup")
    }
    public static func effect(input: AKNode, operation: AKStereoParameter) -> AKCustomEffect {
        return AKCustomEffect(input, sporth:"\(operation)")
    }
    
    public static func stereoEffect(input: AKNode, leftOperation: AKParameter, rightOperation: AKParameter) -> AKCustomEffect {
        return AKCustomEffect(input, sporth:"\(leftOperation) swap \(rightOperation) swap")
    }
    
    public static func generator(operation: AKParameter) -> AKCustomGenerator {
        return AKCustomGenerator("\(operation) dup")
    }
    
    public static func generator(left: AKParameter, _ right: AKParameter) -> AKCustomGenerator {
        return AKCustomGenerator("\(left) \(right)")
    }
}

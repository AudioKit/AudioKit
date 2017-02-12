//
//  AKParameter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AKParameters are simply arguments that can be passed into AKComputedParameters
/// These could be numbers (floats, doubles, ints) or other operations themselves
/// Since parameters can be audio in mono or stereo format, the protocol 
/// requires that an AKParameter defines method to switch between stereo and mono
public protocol AKParameter: CustomStringConvertible {
    /// Require a function to produce a mono operation regarless of the mono/stereo nature of the parameter
    func toMono() -> AKOperation

    /// Require a function to produce a stereo operation regardless of the mono/stereo nature of the parameter
    func toStereo() -> AKStereoOperation
}

/// Default Implementation methods
extension AKParameter {
    /// Most parameters are mono, so the default is just to return the parameter wrapped in a mono operation
    public func toMono() -> AKOperation {
        return AKOperation("\(self) ")
    }

    /// Most parameters are mono, so the dault is to duplicate the parameter in both stereo channels
    public func toStereo() -> AKStereoOperation {
        return AKStereoOperation("\(self) \(self) ")
    }
}

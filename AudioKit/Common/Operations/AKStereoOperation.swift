//
//  AKStereoOperation.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

/// Stereo version of AKComputedParameter
public struct AKStereoOperation: AKComputedParameter {
    
    /// Default stereo input to any operation stack
    public static var input = AKStereoOperation("((14 p) (15 p))")
    
    /// Sporth representation of the stereo operation
    var operationString = ""
    
    /// Redefining description to return the operation string
    public var description: String {
        return "\(operationString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) "
    }
    
    /// Initialize the stereo operation with a Sporth string
    ///
    /// - parameter operationString: Valid Sporth string (proceed with caution
    ///
    public init(_ operationString: String) {
        self.operationString = operationString
    }
    
    /// Create a mono signal by dropping the right channel
    public func toMono() -> AKOperation {
        return self.left()
    }
    
    /// Create a mono signal by dropping the right channel
    public func left() -> AKOperation {
        return AKOperation("(\(self) drop)")
    }

    /// Create a mono signal by dropping the left channel
    public func right() -> AKOperation {
        return AKOperation("(\(self) swap drop)")
    }

    
    /// An operation is requiring a parameter to be stereo, which in this case, it is, so just return self
    public func toStereo() -> AKStereoOperation {
        return self
    }
}

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// OperationParameters are simply arguments that can be passed into ComputedParameters
/// These could be numbers (floats, doubles, ints) or other operations themselves
/// Since parameters can be audio in mono or stereo format, the protocol
/// requires that an OperationParameter defines method to switch between stereo and mono
public protocol OperationParameter: CustomStringConvertible {
    /// Require a function to produce a mono operation regarless of the mono/stereo nature of the parameter
    func toMono() -> Operation

    /// Require a function to produce a stereo operation regardless of the mono/stereo nature of the parameter
    func toStereo() -> StereoOperation
}

/// Default Implementation methods
extension OperationParameter {
    /// Most parameters are mono, so the default is just to return the parameter wrapped in a mono operation
    public func toMono() -> Operation {
        return Operation("\(self) ")
    }

    /// Most parameters are mono, so the dault is to duplicate the parameter in both stereo channels
    public func toStereo() -> StereoOperation {
        return StereoOperation("\(self) \(self) ")
    }
}

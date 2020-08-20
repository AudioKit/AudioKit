// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// MARK: Numeric Protocol

/// Very simple protoocol for anything with an instrinsic floating point value.
/// Allows constants to be passed into an AudioKit operation as well as other operations.
public protocol Numeric: AKParameter {
    /// Raw value of the numeric parameter
    func value() -> Double
}

/// Numeric extension for doubles
extension Double: Numeric {
    /// Get basic value as a double
    public func value() -> Double {
        return Double(self)
    }
}

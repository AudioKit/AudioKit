// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Save a value into the parameters array for using outside of the operation
    ///
    /// - parameter parameterIndex: Location in the parameters array to save this value
    ///
    public func save(parameterIndex: Int) -> Operation {
        return Operation(module: "dup \(parameterIndex) pset", inputs: toMono())
    }
}

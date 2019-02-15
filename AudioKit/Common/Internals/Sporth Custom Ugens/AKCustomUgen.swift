//
//  AKCustomUgen.swift
//  AudioKit
//
//  Created by Joseph Constantakis, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Custom Sporth Unit Generator (Ugen)
open class AKCustomUgen: NSObject {

    /// Name of the Ugen
    @objc public let name: String

    /// String describing the arugments: f for float / s for string, e.g. "fsf"
    @objc public let argTypes: String

    /// Custom object that may be passed in
    @objc open var userData: Any?

    /// Callback / Closure / Function to be called
    public let computeFunction: (AKCustomUgen, AKSporthStack, inout Any?) -> Void

    /// The sporth stack
    @objc public var stack = AKSporthStack()

    /// Initialize the custom unit generator
    public init(name: String,
                argTypes: String,
                userData: Any? = nil,
                computeFunction: @escaping (AKCustomUgen, AKSporthStack, inout Any?) -> Void) {
        self.name = name
        self.argTypes = argTypes
        self.computeFunction = computeFunction
        self.userData = userData
    }

    /// Duplicate the Ugen
    @objc public func duplicate() -> AKCustomUgen {
        return AKCustomUgen(name: self.name,
                            argTypes: self.argTypes,
                            userData: self.userData,
                            computeFunction: self.computeFunction)
    }

    /// Executre the compute function
    @objc public let callComputeFunction: @convention(c) (AKCustomUgen) -> Void
        = { ugen in
            ugen.computeFunction(ugen, ugen.stack, &(ugen.userData))
    }
}

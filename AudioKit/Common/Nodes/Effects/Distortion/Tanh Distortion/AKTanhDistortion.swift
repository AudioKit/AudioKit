//
//  AKTanhDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// Distortion using a modified hyperbolic tangent function.
///
open class AKTanhDistortion: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKTanhDistortionAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Pregain
    public static let pregainRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Lower and upper bounds for Postgain
    public static let postgainRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Lower and upper bounds for Positive Shape Parameter
    public static let positiveShapeParameterRange: ClosedRange<Double> = -10.0 ... 10.0

    /// Lower and upper bounds for Negative Shape Parameter
    public static let negativeShapeParameterRange: ClosedRange<Double> = -10.0 ... 10.0

    /// Initial value for Pregain
    public static let defaultPregain: Double = 2.0

    /// Initial value for Postgain
    public static let defaultPostgain: Double = 0.5

    /// Initial value for Positive Shape Parameter
    public static let defaultPositiveShapeParameter: Double = 0.0

    /// Initial value for Negative Shape Parameter
    public static let defaultNegativeShapeParameter: Double = 0.0

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    open var pregain: Double = defaultPregain {
        willSet {
            let clampedValue = AKTanhDistortion.pregainRange.clamp(newValue)
            guard pregain != clampedValue else { return }
            internalAU?.pregain.value = AUValue(clampedValue)
        }
    }

    /// Gain applied after waveshaping
    open var postgain: Double = defaultPostgain {
        willSet {
            let clampedValue = AKTanhDistortion.postgainRange.clamp(newValue)
            guard postgain != clampedValue else { return }
            internalAU?.postgain.value = AUValue(clampedValue)
        }
    }

    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    open var positiveShapeParameter: Double = defaultPositiveShapeParameter {
        willSet {
            let clampedValue = AKTanhDistortion.positiveShapeParameterRange.clamp(newValue)
            guard positiveShapeParameter != clampedValue else { return }
            internalAU?.positiveShapeParameter.value = AUValue(clampedValue)
        }
    }

    /// Like the positive shape parameter, only for the negative part.
    open var negativeShapeParameter: Double = defaultNegativeShapeParameter {
        willSet {
            let clampedValue = AKTanhDistortion.negativeShapeParameterRange.clamp(newValue)
            guard negativeShapeParameter != clampedValue else { return }
            internalAU?.negativeShapeParameter.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this distortion node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pregain: Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    ///   - postgain: Gain applied after waveshaping
    ///   - positiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    ///   - negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///
    public init(
        _ input: AKNode? = nil,
        pregain: Double = defaultPregain,
        postgain: Double = defaultPostgain,
        positiveShapeParameter: Double = defaultPositiveShapeParameter,
        negativeShapeParameter: Double = defaultNegativeShapeParameter
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.pregain = pregain
            self.postgain = postgain
            self.positiveShapeParameter = positiveShapeParameter
            self.negativeShapeParameter = negativeShapeParameter
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}

//
//  AKTanhDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Distortion using a modified hyperbolic tangent function.
///
open class AKTanhDistortion: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKTanhDistortionAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var pregainParameter: AUParameter?
    fileprivate var postgainParameter: AUParameter?
    fileprivate var positiveShapeParameterParameter: AUParameter?
    fileprivate var negativeShapeParameterParameter: AUParameter?

    /// Lower and upper bounds for Pregain
    public static let pregainRange = 0.0 ... 10.0

    /// Lower and upper bounds for Postgain
    public static let postgainRange = 0.0 ... 10.0

    /// Lower and upper bounds for Positive Shape Parameter
    public static let positiveShapeParameterRange = -10.0 ... 10.0

    /// Lower and upper bounds for Negative Shape Parameter
    public static let negativeShapeParameterRange = -10.0 ... 10.0

    /// Initial value for Pregain
    public static let defaultPregain = 2.0

    /// Initial value for Postgain
    public static let defaultPostgain = 0.5

    /// Initial value for Positive Shape Parameter
    public static let defaultPositiveShapeParameter = 0.0

    /// Initial value for Negative Shape Parameter
    public static let defaultNegativeShapeParameter = 0.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @objc open dynamic var pregain: Double = defaultPregain {
        willSet {
            if pregain == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    pregainParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.pregain, value: newValue)
        }
    }

    /// Gain applied after waveshaping
    @objc open dynamic var postgain: Double = defaultPostgain {
        willSet {
            if postgain == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    postgainParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.postgain, value: newValue)
        }
    }

    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    @objc open dynamic var positiveShapeParameter: Double = defaultPositiveShapeParameter {
        willSet {
            if positiveShapeParameter == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    positiveShapeParameterParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.positiveShapeParameter, value: newValue)
        }
    }

    /// Like the positive shape parameter, only for the negative part.
    @objc open dynamic var negativeShapeParameter: Double = defaultNegativeShapeParameter {
        willSet {
            if negativeShapeParameter == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    negativeShapeParameterParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.negativeShapeParameter, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
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
    @objc public init(
        _ input: AKNode? = nil,
        pregain: Double = defaultPregain,
        postgain: Double = defaultPostgain,
        positiveShapeParameter: Double = defaultPositiveShapeParameter,
        negativeShapeParameter: Double = defaultNegativeShapeParameter
        ) {

        self.pregain = pregain
        self.postgain = postgain
        self.positiveShapeParameter = positiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        pregainParameter = tree["pregain"]
        postgainParameter = tree["postgain"]
        positiveShapeParameterParameter = tree["positiveShapeParameter"]
        negativeShapeParameterParameter = tree["negativeShapeParameter"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.setParameterImmediately(.pregain, value: pregain)
        internalAU?.setParameterImmediately(.postgain, value: postgain)
        internalAU?.setParameterImmediately(.positiveShapeParameter, value: positiveShapeParameter)
        internalAU?.setParameterImmediately(.negativeShapeParameter, value: negativeShapeParameter)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}

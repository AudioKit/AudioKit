//
//  AKTanhDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
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

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    @objc open dynamic var pregain: Double = 2.0 {
        willSet {
            if pregain != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        pregainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.pregain = Float(newValue)
                }
            }
        }
    }
    /// Gain applied after waveshaping
    @objc open dynamic var postgain: Double = 0.5 {
        willSet {
            if postgain != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        postgainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.postgain = Float(newValue)
                }
            }
        }
    }
    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    @objc open dynamic var positiveShapeParameter: Double = 0.0 {
        willSet {
            if positiveShapeParameter != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        positiveShapeParameterParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.positiveShapeParameter = Float(newValue)
                }
            }
        }
    }
    /// Like the positive shape parameter, only for the negative part.
    @objc open dynamic var negativeShapeParameter: Double = 0.0 {
        willSet {
            if negativeShapeParameter != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        negativeShapeParameterParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.negativeShapeParameter = Float(newValue)
                }
            }
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
    ///   - pregain: The amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    ///   - postgain: Gain applied after waveshaping
    ///   - positiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    ///   - negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        pregain: Double = 2.0,
        postgain: Double = 0.5,
        positiveShapeParameter: Double = 0.0,
        negativeShapeParameter: Double = 0.0) {

        self.pregain = pregain
        self.postgain = postgain
        self.positiveShapeParameter = positiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
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

        internalAU?.pregain = Float(pregain)
        internalAU?.postgain = Float(postgain)
        internalAU?.positiveShapeParameter = Float(positiveShapeParameter)
        internalAU?.negativeShapeParameter = Float(negativeShapeParameter)
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

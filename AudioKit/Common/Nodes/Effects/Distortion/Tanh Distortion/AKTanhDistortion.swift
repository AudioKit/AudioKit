//
//  AKTanhDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Distortion using a modified hyperbolic tangent function.
///
open class AKTanhDistortion: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKTanhDistortionAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var pregainParameter: AUParameter?
    fileprivate var postgainParameter: AUParameter?
    fileprivate var postiveShapeParameterParameter: AUParameter?
    fileprivate var negativeShapeParameterParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    open dynamic var pregain: Double = 2.0 {
        willSet {
            if pregain != newValue {
                if internalAU?.isSetUp() ?? false {
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
    open dynamic var postgain: Double = 0.5 {
        willSet {
            if postgain != newValue {
                if internalAU?.isSetUp() ?? false {
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
    open dynamic var postiveShapeParameter: Double = 0.0 {
        willSet {
            if postiveShapeParameter != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                    postiveShapeParameterParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.postiveShapeParameter = Float(newValue)
                }
            }
        }
    }
    /// Like the positive shape parameter, only for the negative part.
    open dynamic var negativeShapeParameter: Double = 0.0 {
        willSet {
            if negativeShapeParameter != newValue {
                if internalAU?.isSetUp() ?? false {
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
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this distortion node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pregain: The amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    ///   - postgain: Gain applied after waveshaping
    ///   - postiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    ///   - negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///
    public init(
        _ input: AKNode,
        pregain: Double = 2.0,
        postgain: Double = 0.5,
        postiveShapeParameter: Double = 0.0,
        negativeShapeParameter: Double = 0.0) {

        self.pregain = pregain
        self.postgain = postgain
        self.postiveShapeParameter = postiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        pregainParameter = tree["pregain"]
        postgainParameter = tree["postgain"]
        postiveShapeParameterParameter = tree["postiveShapeParameter"]
        negativeShapeParameterParameter = tree["negativeShapeParameter"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.pregainParameter?.address {
                    self?.pregain = Double(value)
                } else if address == self?.postgainParameter?.address {
                    self?.postgain = Double(value)
                } else if address == self?.postiveShapeParameterParameter?.address {
                    self?.postiveShapeParameter = Double(value)
                } else if address == self?.negativeShapeParameterParameter?.address {
                    self?.negativeShapeParameter = Double(value)
                }
            }
        })

        internalAU?.pregain = Float(pregain)
        internalAU?.postgain = Float(postgain)
        internalAU?.postiveShapeParameter = Float(postiveShapeParameter)
        internalAU?.negativeShapeParameter = Float(negativeShapeParameter)
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

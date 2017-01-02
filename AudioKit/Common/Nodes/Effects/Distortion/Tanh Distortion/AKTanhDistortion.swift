//
//  AKTanhDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Distortion using a modified hyperbolic tangent function.
///
open class AKTanhDistortion: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKTanhDistortionAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "dist")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var pregainParameter: AUParameter?
    fileprivate var postgainParameter: AUParameter?
    fileprivate var postiveShapeParameterParameter: AUParameter?
    fileprivate var negativeShapeParameterParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    open var pregain: Double = 2.0 {
        willSet {
            if pregain != newValue {
                if internalAU!.isSetUp() {
                    pregainParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.pregain = Float(newValue)
                }
            }
        }
    }
    /// Gain applied after waveshaping
    open var postgain: Double = 0.5 {
        willSet {
            if postgain != newValue {
                if internalAU!.isSetUp() {
                    postgainParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.postgain = Float(newValue)
                }
            }
        }
    }
    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    open var postiveShapeParameter: Double = 0.0 {
        willSet {
            if postiveShapeParameter != newValue {
                if internalAU!.isSetUp() {
                    postiveShapeParameterParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.postiveShapeParameter = Float(newValue)
                }
            }
        }
    }
    /// Like the positive shape parameter, only for the negative part.
    open var negativeShapeParameter: Double = 0.0 {
        willSet {
            if negativeShapeParameter != newValue {
                if internalAU!.isSetUp() {
                    negativeShapeParameterParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.negativeShapeParameter = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this distortion node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - pregain: Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
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
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        pregainParameter = tree["pregain"]
        postgainParameter = tree["postgain"]
        postiveShapeParameterParameter = tree["postiveShapeParameter"]
        negativeShapeParameterParameter = tree["negativeShapeParameter"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.pregainParameter!.address {
                    self.pregain = Double(value)
                } else if address == self.postgainParameter!.address {
                    self.postgain = Double(value)
                } else if address == self.postiveShapeParameterParameter!.address {
                    self.postiveShapeParameter = Double(value)
                } else if address == self.negativeShapeParameterParameter!.address {
                    self.negativeShapeParameter = Double(value)
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
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}

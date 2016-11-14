//
//  AKToneFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// A first-order recursive low-pass filter with variable frequency response.
///
/// - Parameters:
///   - input: Input node to process
///   - halfPowerPoint: The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
///
open class AKToneFilter: AKNode, AKToggleable, AKComponent {
    static let ComponentDescription = AudioComponentDescription(effect: "tone")

    // MARK: - Properties

    internal var internalAU: AKToneFilterAudioUnit?
    internal var token: AUParameterObserverToken?

    fileprivate var halfPowerPointParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    open var halfPowerPoint: Double = 1000.0 {
        willSet {
            if halfPowerPoint != newValue {
                if internalAU!.isSetUp() {
                    halfPowerPointParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.halfPowerPoint = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - halfPowerPoint: The response curve's half-power point, in Hertz. Half power is defined as peak power / root 2.
    ///
    public init(
        _ input: AKNode,
        halfPowerPoint: Double = 1000.0) {

        self.halfPowerPoint = halfPowerPoint

        _Self.register(AKToneFilterAudioUnit.self)

        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKToneFilterAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        halfPowerPointParameter = tree["halfPowerPoint"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.halfPowerPointParameter!.address {
                    self.halfPowerPoint = Double(value)
                }
            }
        })

        internalAU?.halfPowerPoint = Float(halfPowerPoint)
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

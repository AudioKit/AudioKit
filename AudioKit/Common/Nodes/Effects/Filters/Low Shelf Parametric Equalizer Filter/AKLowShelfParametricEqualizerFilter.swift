//
//  AKLowShelfParametricEqualizerFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
/// - Parameters:
///   - input: Input node to process
///   - cornerFrequency: Corner frequency.
///   - gain: Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
///   - q: Q of the filter. sqrt(0.5) is no resonance.
///
open class AKLowShelfParametricEqualizerFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKLowShelfParametricEqualizerFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "peq1")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    internal var token: AUParameterObserverToken?

    fileprivate var cornerFrequencyParameter: AUParameter?
    fileprivate var gainParameter: AUParameter?
    fileprivate var qParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Corner frequency.
    open var cornerFrequency: Double = 1000 {
        willSet {
            if cornerFrequency != newValue {
                if internalAU!.isSetUp() {
                    cornerFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.cornerFrequency = Float(newValue)
                }
            }
        }
    }
    /// Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    open var gain: Double = 1.0 {
        willSet {
            if gain != newValue {
                if internalAU!.isSetUp() {
                    gainParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.gain = Float(newValue)
                }
            }
        }
    }
    /// Q of the filter. sqrt(0.5) is no resonance.
    open var q: Double = 0.707 {
        willSet {
            if q != newValue {
                if internalAU!.isSetUp() {
                    qParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.q = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cornerFrequency: Corner frequency.
    ///   - gain: Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    ///   - q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    public init(
        _ input: AKNode,
        cornerFrequency: Double = 1000,
        gain: Double = 1.0,
        q: Double = 0.707) {

        self.cornerFrequency = cornerFrequency
        self.gain = gain
        self.q = q

        _Self.register()

        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cornerFrequencyParameter = tree["cornerFrequency"]
        gainParameter            = tree["gain"]
        qParameter               = tree["q"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.cornerFrequencyParameter!.address {
                    self.cornerFrequency = Double(value)
                } else if address == self.gainParameter!.address {
                    self.gain = Double(value)
                } else if address == self.qParameter!.address {
                    self.q = Double(value)
                }
            }
        })

        internalAU?.cornerFrequency = Float(cornerFrequency)
        internalAU?.gain = Float(gain)
        internalAU?.q = Float(q)
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

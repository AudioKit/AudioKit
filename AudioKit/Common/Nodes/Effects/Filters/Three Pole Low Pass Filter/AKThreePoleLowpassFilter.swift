//
//  AKThreePoleLowpassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
/// - Parameters:
///   - input: Input node to process
///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
///   - cutoffFrequency: Filter cutoff frequency in Hertz.
///   - resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
///
open class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKThreePoleLowpassFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    internal var token: AUParameterObserverToken?

    fileprivate var distortionParameter: AUParameter?
    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    open var distortion: Double = 0.5 {
        willSet {
            if distortion != newValue {
                if internalAU!.isSetUp() {
                    distortionParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.distortion = Float(newValue)
                }
            }
        }
    }
    /// Filter cutoff frequency in Hertz.
    open var cutoffFrequency: Double = 1500 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU!.isSetUp() {
                    cutoffFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }
    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    open var resonance: Double = 0.5 {
        willSet {
            if resonance != newValue {
                if internalAU!.isSetUp() {
                    resonanceParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.resonance = Float(newValue)
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
    ///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz.
    ///   - resonance: Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    ///
    public init(
        _ input: AKNode,
        distortion: Double = 0.5,
        cutoffFrequency: Double = 1500,
        resonance: Double = 0.5) {

        self.distortion = distortion
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

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

        distortionParameter      = tree["distortion"]
        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter       = tree["resonance"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.distortionParameter!.address {
                    self.distortion = Double(value)
                } else if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                }
            }
        })

        internalAU?.distortion = Float(distortion)
        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
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

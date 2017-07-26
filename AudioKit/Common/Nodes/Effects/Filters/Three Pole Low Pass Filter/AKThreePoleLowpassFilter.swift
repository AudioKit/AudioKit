//
//  AKThreePoleLowpassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
open class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKThreePoleLowpassFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var distortionParameter: AUParameter?
    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by the
    /// filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    open dynamic var distortion: Double = 0.5 {
        willSet {
            if distortion != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        distortionParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.distortion = Float(newValue)
                }
            }
        }
    }
    /// Filter cutoff frequency in Hertz.
    open dynamic var cutoffFrequency: Double = 1_500 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        cutoffFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }
    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency.
    /// Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    open dynamic var resonance: Double = 0.5 {
        willSet {
            if resonance != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        resonanceParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.resonance = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - distortion: Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion
    ///                 controlled by the filter parameters, in such a way that both low cutoff and high resonance
    ///                 increase the distortion amount.
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz.
    ///   - resonance: Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency.
    ///                Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive”
    ///                effect.
    ///
    public init(
        _ input: AKNode?,
        distortion: Double = 0.5,
        cutoffFrequency: Double = 1_500,
        resonance: Double = 0.5) {

        self.distortion = distortion
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        distortionParameter = tree["distortion"]
        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.distortion = Float(distortion)
        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
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

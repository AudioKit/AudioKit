//
//  AKKorgLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Analog model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var saturationParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Filter cutoff
    open dynamic var cutoffFrequency: Double = 1_000.0 {
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
    /// Filter resonance (should be between 0-2)
    open dynamic var resonance: Double = 1.0 {
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
    /// Filter saturation.
    open dynamic var saturation: Double = 0.0 {
        willSet {
            if saturation != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        saturationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.saturation = Float(newValue)
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
    /// - parameter input: Input node to process
    /// - parameter cutoffFrequency: Filter cutoff
    /// - parameter resonance: Filter resonance (should be between 0-2)
    /// - parameter saturation: Filter saturation.
    ///
    public init(
        _ input: AKNode?,
        cutoffFrequency: Double = 1_000.0,
        resonance: Double = 1.0,
        saturation: Double = 0.0) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.saturation = saturation

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]
        saturationParameter = tree["saturation"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.cutoffFrequencyParameter?.address {
                    self?.cutoffFrequency = Double(value)
                } else if address == self?.resonanceParameter?.address {
                    self?.resonance = Double(value)
                } else if address == self?.saturationParameter?.address {
                    self?.saturation = Double(value)
                }
            }
        })

        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
        internalAU?.saturation = Float(saturation)
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

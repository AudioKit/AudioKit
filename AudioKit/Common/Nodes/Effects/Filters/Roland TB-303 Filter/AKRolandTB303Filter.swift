//
//  AKRolandTB303Filter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Emulation of the Roland TB-303 filter
///
open class AKRolandTB303Filter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKRolandTB303FilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "tb3f")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var distortionParameter: AUParameter?
    fileprivate var resonanceAsymmetryParameter: AUParameter?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange = 0.0 ... 2.0

    /// Lower and upper bounds for Distortion
    public static let distortionRange = 0.0 ... 4.0

    /// Lower and upper bounds for Resonance Asymmetry
    public static let resonanceAsymmetryRange = 0.0 ... 1.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency = 500.0

    /// Initial value for Resonance
    public static let defaultResonance = 0.5

    /// Initial value for Distortion
    public static let defaultDistortion = 2.0

    /// Initial value for Resonance Asymmetry
    public static let defaultResonanceAsymmetry = 0.5

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Cutoff frequency. (in Hertz)
    @objc open dynamic var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            if cutoffFrequency == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    cutoffFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.cutoffFrequency, value: newValue)
        }
    }

    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    @objc open dynamic var resonance: Double = defaultResonance {
        willSet {
            if resonance == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    resonanceParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.resonance, value: newValue)
        }
    }

    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    @objc open dynamic var distortion: Double = defaultDistortion {
        willSet {
            if distortion == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    distortionParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.distortion, value: newValue)
        }
    }

    /// Asymmetry of resonance. Value is between 0-1
    @objc open dynamic var resonanceAsymmetry: Double = defaultResonanceAsymmetry {
        willSet {
            if resonanceAsymmetry == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    resonanceAsymmetryParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.resonanceAsymmetry, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    ///   - distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    ///   - resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
    ///
    @objc public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency,
        resonance: Double = defaultResonance,
        distortion: Double = defaultDistortion,
        resonanceAsymmetry: Double = defaultResonanceAsymmetry
        ) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.distortion = distortion
        self.resonanceAsymmetry = resonanceAsymmetry

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter = tree["resonance"]
        distortionParameter = tree["distortion"]
        resonanceAsymmetryParameter = tree["resonanceAsymmetry"]

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

        internalAU?.setParameterImmediately(.cutoffFrequency, value: cutoffFrequency)
        internalAU?.setParameterImmediately(.resonance, value: resonance)
        internalAU?.setParameterImmediately(.distortion, value: distortion)
        internalAU?.setParameterImmediately(.resonanceAsymmetry, value: resonanceAsymmetry)
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

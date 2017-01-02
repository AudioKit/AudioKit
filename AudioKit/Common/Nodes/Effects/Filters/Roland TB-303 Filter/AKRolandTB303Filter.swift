//
//  AKRolandTB303Filter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Emulation of the Roland TB-303 filter
///
open class AKRolandTB303Filter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKRolandTB303FilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "tb3f")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var distortionParameter: AUParameter?
    fileprivate var resonanceAsymmetryParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Cutoff frequency. (in Hertz)
    open var cutoffFrequency: Double = 500 {
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
    /// Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
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
    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    open var distortion: Double = 2.0 {
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
    /// Asymmetry of resonance. Value is between 0-1
    open var resonanceAsymmetry: Double = 0.5 {
        willSet {
            if resonanceAsymmetry != newValue {
                if internalAU!.isSetUp() {
                    resonanceAsymmetryParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.resonanceAsymmetry = Float(newValue)
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
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    ///   - distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    ///   - resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 500,
        resonance: Double = 0.5,
        distortion: Double = 2.0,
        resonanceAsymmetry: Double = 0.5) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.distortion = distortion
        self.resonanceAsymmetry = resonanceAsymmetry

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) {
            avAudioUnit in

            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        cutoffFrequencyParameter    = tree["cutoffFrequency"]
        resonanceParameter          = tree["resonance"]
        distortionParameter         = tree["distortion"]
        resonanceAsymmetryParameter = tree["resonanceAsymmetry"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                } else if address == self.distortionParameter!.address {
                    self.distortion = Double(value)
                } else if address == self.resonanceAsymmetryParameter!.address {
                    self.resonanceAsymmetry = Double(value)
                }
            }
        })

        internalAU?.cutoffFrequency = Float(cutoffFrequency)
        internalAU?.resonance = Float(resonance)
        internalAU?.distortion = Float(distortion)
        internalAU?.resonanceAsymmetry = Float(resonanceAsymmetry)
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

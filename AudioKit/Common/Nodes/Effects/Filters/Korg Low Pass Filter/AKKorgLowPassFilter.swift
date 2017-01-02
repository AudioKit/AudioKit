//
//  AKKorgLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Analog model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var cutoffFrequencyParameter: AUParameter?
    fileprivate var resonanceParameter: AUParameter?
    fileprivate var saturationParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Filter cutoff
    open var cutoffFrequency: Double = 1000.0 {
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
    /// Filter resonance (should be between 0-2)
    open var resonance: Double = 1.0 {
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
    /// Filter saturation.
    open var saturation: Double = 0.0 {
        willSet {
            if saturation != newValue {
                if internalAU!.isSetUp() {
                    saturationParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.saturation = Float(newValue)
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
    /// - parameter input: Input node to process
    /// - parameter cutoffFrequency: Filter cutoff
    /// - parameter resonance: Filter resonance (should be between 0-2)
    /// - parameter saturation: Filter saturation.
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 1000.0,
        resonance: Double = 1.0,
        saturation: Double = 0.0) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.saturation = saturation

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

        cutoffFrequencyParameter = tree["cutoffFrequency"]
        resonanceParameter       = tree["resonance"]
        saturationParameter      = tree["saturation"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = Double(value)
                } else if address == self.resonanceParameter!.address {
                    self.resonance = Double(value)
                } else if address == self.saturationParameter!.address {
                    self.saturation = Double(value)
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
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}

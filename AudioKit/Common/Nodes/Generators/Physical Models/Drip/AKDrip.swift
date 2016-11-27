//
//  AKDrip.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
/// - Parameters:
///   - intensity: The intensity of the dripping sound.
///   - dampingFactor: The damping factor. Maximum value is 2.0.
///   - energyReturn: The amount of energy to add back into the system.
///   - mainResonantFrequency: Main resonant frequency.
///   - firstResonantFrequency: The first resonant frequency.
///   - secondResonantFrequency: The second resonant frequency.
///   - amplitude: Amplitude.
///
open class AKDrip: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKDripAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    internal var token: AUParameterObserverToken?


    fileprivate var intensityParameter: AUParameter?
    fileprivate var dampingFactorParameter: AUParameter?
    fileprivate var energyReturnParameter: AUParameter?
    fileprivate var mainResonantFrequencyParameter: AUParameter?
    fileprivate var firstResonantFrequencyParameter: AUParameter?
    fileprivate var secondResonantFrequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// The intensity of the dripping sound.
    open var intensity: Double = 10 {
        willSet {
            if intensity != newValue {
                intensityParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The damping factor. Maximum value is 2.0.
    open var dampingFactor: Double = 0.2 {
        willSet {
            if dampingFactor != newValue {
                dampingFactorParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The amount of energy to add back into the system.
    open var energyReturn: Double = 0 {
        willSet {
            if energyReturn != newValue {
                energyReturnParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Main resonant frequency.
    open var mainResonantFrequency: Double = 450 {
        willSet {
            if mainResonantFrequency != newValue {
                mainResonantFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The first resonant frequency.
    open var firstResonantFrequency: Double = 600 {
        willSet {
            if firstResonantFrequency != newValue {
                firstResonantFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The second resonant frequency.
    open var secondResonantFrequency: Double = 750 {
        willSet {
            if secondResonantFrequency != newValue {
                secondResonantFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Amplitude.
    open var amplitude: Double = 0.3 {
        willSet {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize the drip with defaults
    public convenience override init() {
        self.init(intensity: 10)
    }

    /// Initialize this drip node
    ///
    /// - Parameters:
    ///   - intensity: The intensity of the dripping sound.
    ///   - dampingFactor: The damping factor. Maximum value is 2.0.
    ///   - energyReturn: The amount of energy to add back into the system.
    ///   - mainResonantFrequency: Main resonant frequency.
    ///   - firstResonantFrequency: The first resonant frequency.
    ///   - secondResonantFrequency: The second resonant frequency.
    ///   - amplitude: Amplitude.
    ///
    public init(
        intensity: Double,
        dampingFactor: Double = 0.2,
        energyReturn: Double = 0,
        mainResonantFrequency: Double = 450,
        firstResonantFrequency: Double = 600,
        secondResonantFrequency: Double = 750,
        amplitude: Double = 0.3) {

        self.intensity = intensity
        self.dampingFactor = dampingFactor
        self.energyReturn = energyReturn
        self.mainResonantFrequency = mainResonantFrequency
        self.firstResonantFrequency = firstResonantFrequency
        self.secondResonantFrequency = secondResonantFrequency
        self.amplitude = amplitude

        _Self.register()

        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        intensityParameter               = tree["intensity"]
        dampingFactorParameter           = tree["dampingFactor"]
        energyReturnParameter            = tree["energyReturn"]
        mainResonantFrequencyParameter   = tree["mainResonantFrequency"]
        firstResonantFrequencyParameter  = tree["firstResonantFrequency"]
        secondResonantFrequencyParameter = tree["secondResonantFrequency"]
        amplitudeParameter               = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.intensityParameter!.address {
                    self.intensity = Double(value)
                } else if address == self.dampingFactorParameter!.address {
                    self.dampingFactor = Double(value)
                } else if address == self.energyReturnParameter!.address {
                    self.energyReturn = Double(value)
                } else if address == self.mainResonantFrequencyParameter!.address {
                    self.mainResonantFrequency = Double(value)
                } else if address == self.firstResonantFrequencyParameter!.address {
                    self.firstResonantFrequency = Double(value)
                } else if address == self.secondResonantFrequencyParameter!.address {
                    self.secondResonantFrequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        })
        internalAU?.intensity = Float(intensity)
        internalAU?.dampingFactor = Float(dampingFactor)
        internalAU?.energyReturn = Float(energyReturn)
        internalAU?.mainResonantFrequency = Float(mainResonantFrequency)
        internalAU?.firstResonantFrequency = Float(firstResonantFrequency)
        internalAU?.secondResonantFrequency = Float(secondResonantFrequency)
        internalAU?.amplitude = Float(amplitude)
    }

    // MARK: - Control

    /// Trigger the sound with an optional set of parameters
    ///
    open func trigger() {
        self.internalAU!.start()
        self.internalAU!.trigger()
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}

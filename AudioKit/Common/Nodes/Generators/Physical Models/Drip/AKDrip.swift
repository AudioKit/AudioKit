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
/// - parameter intensity: The intensity of the dripping sound.
/// - parameter dampingFactor: The damping factor. Maximum value is 2.0.
/// - parameter energyReturn: The amount of energy to add back into the system.
/// - parameter mainResonantFrequency: Main resonant frequency.
/// - parameter firstResonantFrequency: The first resonant frequency.
/// - parameter secondResonantFrequency: The second resonant frequency.
/// - parameter amplitude: Amplitude.
///
public class AKDrip: AKNode {

    // MARK: - Properties

    internal var internalAU: AKDripAudioUnit?
    internal var token: AUParameterObserverToken?


    private var intensityParameter: AUParameter?
    private var dampingFactorParameter: AUParameter?
    private var energyReturnParameter: AUParameter?
    private var mainResonantFrequencyParameter: AUParameter?
    private var firstResonantFrequencyParameter: AUParameter?
    private var secondResonantFrequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// The intensity of the dripping sound.
    public var intensity: Double = 10 {
        willSet {
            if intensity != newValue {
                intensityParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The damping factor. Maximum value is 2.0.
    public var dampingFactor: Double = 0.2 {
        willSet {
            if dampingFactor != newValue {
                dampingFactorParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The amount of energy to add back into the system.
    public var energyReturn: Double = 0 {
        willSet {
            if energyReturn != newValue {
                energyReturnParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Main resonant frequency.
    public var mainResonantFrequency: Double = 450 {
        willSet {
            if mainResonantFrequency != newValue {
                mainResonantFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The first resonant frequency.
    public var firstResonantFrequency: Double = 600 {
        willSet {
            if firstResonantFrequency != newValue {
                firstResonantFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// The second resonant frequency.
    public var secondResonantFrequency: Double = 750 {
        willSet {
            if secondResonantFrequency != newValue {
                secondResonantFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Amplitude.
    public var amplitude: Double = 0.3 {
        willSet {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization
    
    /// Initialize the drip with defaults
    convenience override init() {
        self.init(intensity: 10)
    }

    /// Initialize this drip node
    ///
    /// - parameter intensity: The intensity of the dripping sound.
    /// - parameter dampingFactor: The damping factor. Maximum value is 2.0.
    /// - parameter energyReturn: The amount of energy to add back into the system.
    /// - parameter mainResonantFrequency: Main resonant frequency.
    /// - parameter firstResonantFrequency: The first resonant frequency.
    /// - parameter secondResonantFrequency: The second resonant frequency.
    /// - parameter amplitude: Amplitude.
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

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x64726970 /*'drip'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKDripAudioUnit.self,
            as: description,
            name: "Local AKDrip",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKDripAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        intensityParameter               = tree.value(forKey: "intensity")               as? AUParameter
        dampingFactorParameter           = tree.value(forKey: "dampingFactor")           as? AUParameter
        energyReturnParameter            = tree.value(forKey: "energyReturn")            as? AUParameter
        mainResonantFrequencyParameter   = tree.value(forKey: "mainResonantFrequency")   as? AUParameter
        firstResonantFrequencyParameter  = tree.value(forKey: "firstResonantFrequency")  as? AUParameter
        secondResonantFrequencyParameter = tree.value(forKey: "secondResonantFrequency") as? AUParameter
        amplitudeParameter               = tree.value(forKey: "amplitude")               as? AUParameter

        token = tree.token {
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
        }
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
    public func trigger() {
        self.internalAU!.start()
        self.internalAU!.trigger()
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}

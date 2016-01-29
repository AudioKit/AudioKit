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

    /// The intensity of the dripping sound.
    public var intensity: Double = 10 {
        didSet {
            internalAU?.intensity = Float(intensity)
        }
    }

    /// Ramp to intensity over 20 ms
    ///
    /// - parameter intensity: Target The intensity of the dripping sound.
    ///
    public func ramp(intensity intensity: Double) {
        intensityParameter?.setValue(Float(intensity), originator: token!)
    }

    /// The damping factor. Maximum value is 2.0.
    public var dampingFactor: Double = 0.2 {
        didSet {
            internalAU?.dampingFactor = Float(dampingFactor)
        }
    }

    /// Ramp to dampingFactor over 20 ms
    ///
    /// - parameter dampingFactor: Target The damping factor. Maximum value is 2.0.
    ///
    public func ramp(dampingFactor dampingFactor: Double) {
        dampingFactorParameter?.setValue(Float(dampingFactor), originator: token!)
    }

    /// The amount of energy to add back into the system.
    public var energyReturn: Double = 0 {
        didSet {
            internalAU?.energyReturn = Float(energyReturn)
        }
    }

    /// Ramp to energyReturn over 20 ms
    ///
    /// - parameter energyReturn: Target The amount of energy to add back into the system.
    ///
    public func ramp(energyReturn energyReturn: Double) {
        energyReturnParameter?.setValue(Float(energyReturn), originator: token!)
    }

    /// Main resonant frequency.
    public var mainResonantFrequency: Double = 450 {
        didSet {
            internalAU?.mainResonantFrequency = Float(mainResonantFrequency)
        }
    }

    /// Ramp to mainResonantFrequency over 20 ms
    ///
    /// - parameter mainResonantFrequency: Target Main resonant frequency.
    ///
    public func ramp(mainResonantFrequency mainResonantFrequency: Double) {
        mainResonantFrequencyParameter?.setValue(Float(mainResonantFrequency), originator: token!)
    }

    /// The first resonant frequency.
    public var firstResonantFrequency: Double = 600 {
        didSet {
            internalAU?.firstResonantFrequency = Float(firstResonantFrequency)
        }
    }

    /// Ramp to firstResonantFrequency over 20 ms
    ///
    /// - parameter firstResonantFrequency: Target The first resonant frequency.
    ///
    public func ramp(firstResonantFrequency firstResonantFrequency: Double) {
        firstResonantFrequencyParameter?.setValue(Float(firstResonantFrequency), originator: token!)
    }

    /// The second resonant frequency.
    public var secondResonantFrequency: Double = 750 {
        didSet {
            internalAU?.secondResonantFrequency = Float(secondResonantFrequency)
        }
    }

    /// Ramp to secondResonantFrequency over 20 ms
    ///
    /// - parameter secondResonantFrequency: Target The second resonant frequency.
    ///
    public func ramp(secondResonantFrequency secondResonantFrequency: Double) {
        secondResonantFrequencyParameter?.setValue(Float(secondResonantFrequency), originator: token!)
    }

    /// Amplitude.
    public var amplitude: Double = 0.3 {
        didSet {
            internalAU?.amplitude = Float(amplitude)
        }
    }

    /// Ramp to amplitude over 20 ms
    ///
    /// - parameter amplitude: Target Amplitude.
    ///
    public func ramp(amplitude amplitude: Double) {
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
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
            asComponentDescription: description,
            name: "Local AKDrip",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKDripAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        intensityParameter               = tree.valueForKey("intensity")               as? AUParameter
        dampingFactorParameter           = tree.valueForKey("dampingFactor")           as? AUParameter
        energyReturnParameter            = tree.valueForKey("energyReturn")            as? AUParameter
        mainResonantFrequencyParameter   = tree.valueForKey("mainResonantFrequency")   as? AUParameter
        firstResonantFrequencyParameter  = tree.valueForKey("firstResonantFrequency")  as? AUParameter
        secondResonantFrequencyParameter = tree.valueForKey("secondResonantFrequency") as? AUParameter
        amplitudeParameter               = tree.valueForKey("amplitude")               as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
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
    
    /// Trigger the sound with an optional set of parameters
    /// - parameter parameters: An array of doubles to use as parameters
    ///
    public func trigger() {
        self.internalAU!.start()
        self.internalAU!.trigger()
    }
    
    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}

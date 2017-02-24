//
//  AKDrip.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
open class AKDrip: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKDripAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

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
            internalAU?.rampTime = newValue
        }
    }

    /// The intensity of the dripping sound.
    open var intensity: Double = 10 {
        willSet {
            if intensity != newValue {
                if let existingToken = token {
                    intensityParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The damping factor. Maximum value is 2.0.
    open var dampingFactor: Double = 0.2 {
        willSet {
            if dampingFactor != newValue {
                if let existingToken = token {
                    dampingFactorParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The amount of energy to add back into the system.
    open var energyReturn: Double = 0 {
        willSet {
            if energyReturn != newValue {
                if let existingToken = token {
                    energyReturnParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Main resonant frequency.
    open var mainResonantFrequency: Double = 450 {
        willSet {
            if mainResonantFrequency != newValue {
                if let existingToken = token {
                    mainResonantFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The first resonant frequency.
    open var firstResonantFrequency: Double = 600 {
        willSet {
            if firstResonantFrequency != newValue {
                if let existingToken = token {
                    firstResonantFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The second resonant frequency.
    open var secondResonantFrequency: Double = 750 {
        willSet {
            if secondResonantFrequency != newValue {
                if let existingToken = token {
                    secondResonantFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Amplitude.
    open var amplitude: Double = 0.3 {
        willSet {
            if amplitude != newValue {
                if let existingToken = token {
                    amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        intensityParameter = tree["intensity"]
        dampingFactorParameter = tree["dampingFactor"]
        energyReturnParameter = tree["energyReturn"]
        mainResonantFrequencyParameter = tree["mainResonantFrequency"]
        firstResonantFrequencyParameter = tree["firstResonantFrequency"]
        secondResonantFrequencyParameter = tree["secondResonantFrequency"]
        amplitudeParameter = tree["amplitude"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.intensityParameter?.address {
                    self?.intensity = Double(value)
                } else if address == self?.dampingFactorParameter?.address {
                    self?.dampingFactor = Double(value)
                } else if address == self?.energyReturnParameter?.address {
                    self?.energyReturn = Double(value)
                } else if address == self?.mainResonantFrequencyParameter?.address {
                    self?.mainResonantFrequency = Double(value)
                } else if address == self?.firstResonantFrequencyParameter?.address {
                    self?.firstResonantFrequency = Double(value)
                } else if address == self?.secondResonantFrequencyParameter?.address {
                    self?.secondResonantFrequency = Double(value)
                } else if address == self?.amplitudeParameter?.address {
                    self?.amplitude = Double(value)
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
        internalAU?.start()
        internalAU?.trigger()
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}

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
    /// Four letter unique description of the node
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
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// The intensity of the dripping sound.
    @objc open dynamic var intensity: Double = 10 {
        willSet {
            if intensity != newValue {
                if let existingToken = token {
                    intensityParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The damping factor. Maximum value is 2.0.
    @objc open dynamic var dampingFactor: Double = 0.2 {
        willSet {
            if dampingFactor != newValue {
                if let existingToken = token {
                    dampingFactorParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The amount of energy to add back into the system.
    @objc open dynamic var energyReturn: Double = 0 {
        willSet {
            if energyReturn != newValue {
                if let existingToken = token {
                    energyReturnParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Main resonant frequency.
    @objc open dynamic var mainResonantFrequency: Double = 450 {
        willSet {
            if mainResonantFrequency != newValue {
                if let existingToken = token {
                    mainResonantFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The first resonant frequency.
    @objc open dynamic var firstResonantFrequency: Double = 600 {
        willSet {
            if firstResonantFrequency != newValue {
                if let existingToken = token {
                    firstResonantFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// The second resonant frequency.
    @objc open dynamic var secondResonantFrequency: Double = 750 {
        willSet {
            if secondResonantFrequency != newValue {
                if let existingToken = token {
                    secondResonantFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Amplitude.
    @objc open dynamic var amplitude: Double = 0.3 {
        willSet {
            if amplitude != newValue {
                if let existingToken = token {
                    amplitudeParameter?.setValue(Float(newValue), originator: existingToken)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
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
    @objc public init(
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
            AKLog("Parameter Tree Failed")
            return
        }

        intensityParameter = tree["intensity"]
        dampingFactorParameter = tree["dampingFactor"]
        energyReturnParameter = tree["energyReturn"]
        mainResonantFrequencyParameter = tree["mainResonantFrequency"]
        firstResonantFrequencyParameter = tree["firstResonantFrequency"]
        secondResonantFrequencyParameter = tree["secondResonantFrequency"]
        amplitudeParameter = tree["amplitude"]

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
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}

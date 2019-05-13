//
//  AKDrip.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
open class AKDrip: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKDripAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var intensityParameter: AUParameter?
    fileprivate var dampingFactorParameter: AUParameter?
    fileprivate var energyReturnParameter: AUParameter?
    fileprivate var mainResonantFrequencyParameter: AUParameter?
    fileprivate var firstResonantFrequencyParameter: AUParameter?
    fileprivate var secondResonantFrequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Lower and upper bounds for Intensity
    public static let intensityRange = 0.0 ... 100.0

    /// Lower and upper bounds for Damping Factor
    public static let dampingFactorRange = 0.0 ... 2.0

    /// Lower and upper bounds for Energy Return
    public static let energyReturnRange = 0.0 ... 100.0

    /// Lower and upper bounds for Main Resonant Frequency
    public static let mainResonantFrequencyRange = 0.0 ... 22_000.0

    /// Lower and upper bounds for First Resonant Frequency
    public static let firstResonantFrequencyRange = 0.0 ... 22_000.0

    /// Lower and upper bounds for Second Resonant Frequency
    public static let secondResonantFrequencyRange = 0.0 ... 22_000.0

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange = 0.0 ... 1.0

    /// Initial value for Intensity
    public static let defaultIntensity = 10.0

    /// Initial value for Damping Factor
    public static let defaultDampingFactor = 0.2

    /// Initial value for Energy Return
    public static let defaultEnergyReturn = 0.0

    /// Initial value for Main Resonant Frequency
    public static let defaultMainResonantFrequency = 450.0

    /// Initial value for First Resonant Frequency
    public static let defaultFirstResonantFrequency = 600.0

    /// Initial value for Second Resonant Frequency
    public static let defaultSecondResonantFrequency = 750.0

    /// Initial value for Amplitude
    public static let defaultAmplitude = 0.3

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// The intensity of the dripping sound.
    @objc open dynamic var intensity: Double = defaultIntensity {
        willSet {
            guard intensity != newValue else { return }
            if internalAU?.isSetUp == true {
                intensityParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.intensity, value: newValue)
        }
    }

    /// The damping factor. Maximum value is 2.0.
    @objc open dynamic var dampingFactor: Double = defaultDampingFactor {
        willSet {
            guard dampingFactor != newValue else { return }
            if internalAU?.isSetUp == true {
                dampingFactorParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.dampingFactor, value: newValue)
        }
    }

    /// The amount of energy to add back into the system.
    @objc open dynamic var energyReturn: Double = defaultEnergyReturn {
        willSet {
            guard energyReturn != newValue else { return }
            if internalAU?.isSetUp == true {
                energyReturnParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.energyReturn, value: newValue)
        }
    }

    /// Main resonant frequency.
    @objc open dynamic var mainResonantFrequency: Double = defaultMainResonantFrequency {
        willSet {
            guard mainResonantFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                mainResonantFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.mainResonantFrequency, value: newValue)
        }
    }

    /// The first resonant frequency.
    @objc open dynamic var firstResonantFrequency: Double = defaultFirstResonantFrequency {
        willSet {
            guard firstResonantFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                firstResonantFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.firstResonantFrequency, value: newValue)
        }
    }

    /// The second resonant frequency.
    @objc open dynamic var secondResonantFrequency: Double = defaultSecondResonantFrequency {
        willSet {
            guard secondResonantFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                secondResonantFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.secondResonantFrequency, value: newValue)
        }
    }

    /// Amplitude.
    @objc open dynamic var amplitude: Double = defaultAmplitude {
        willSet {
            guard amplitude != newValue else { return }
            if internalAU?.isSetUp == true {
                amplitudeParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.amplitude, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

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
    @available(*, deprecated, message: "The physical model is inherently unstable and unpredictable, use at your own risk/discrertion.")
    @objc public init(
        intensity: Double = 10,
        dampingFactor: Double = defaultDampingFactor,
        energyReturn: Double = defaultEnergyReturn,
        mainResonantFrequency: Double = defaultMainResonantFrequency,
        firstResonantFrequency: Double = defaultFirstResonantFrequency,
        secondResonantFrequency: Double = defaultSecondResonantFrequency,
        amplitude: Double = defaultAmplitude) {

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
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
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
        internalAU?.setParameterImmediately(.intensity, value: intensity)
        internalAU?.setParameterImmediately(.dampingFactor, value: dampingFactor)
        internalAU?.setParameterImmediately(.energyReturn, value: energyReturn)
        internalAU?.setParameterImmediately(.mainResonantFrequency, value: mainResonantFrequency)
        internalAU?.setParameterImmediately(.firstResonantFrequency, value: firstResonantFrequency)
        internalAU?.setParameterImmediately(.secondResonantFrequency, value: secondResonantFrequency)
        internalAU?.setParameterImmediately(.amplitude, value: amplitude)
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

//
//  AKDrip.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
open class AKDrip: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKDripAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Intensity
    public static let intensityRange: ClosedRange<Double> = 0 ... 100

    /// Lower and upper bounds for Damping Factor
    public static let dampingFactorRange: ClosedRange<Double> = 0.0 ... 2.0

    /// Lower and upper bounds for Energy Return
    public static let energyReturnRange: ClosedRange<Double> = 0 ... 100

    /// Lower and upper bounds for Main Resonant Frequency
    public static let mainResonantFrequencyRange: ClosedRange<Double> = 0 ... 22000

    /// Lower and upper bounds for First Resonant Frequency
    public static let firstResonantFrequencyRange: ClosedRange<Double> = 0 ... 22000

    /// Lower and upper bounds for Second Resonant Frequency
    public static let secondResonantFrequencyRange: ClosedRange<Double> = 0 ... 22000

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0 ... 1

    /// Initial value for Intensity
    public static let defaultIntensity: Double = 10

    /// Initial value for Damping Factor
    public static let defaultDampingFactor: Double = 0.2

    /// Initial value for Energy Return
    public static let defaultEnergyReturn: Double = 0

    /// Initial value for Main Resonant Frequency
    public static let defaultMainResonantFrequency: Double = 450

    /// Initial value for First Resonant Frequency
    public static let defaultFirstResonantFrequency: Double = 600

    /// Initial value for Second Resonant Frequency
    public static let defaultSecondResonantFrequency: Double = 750

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 0.3

    /// The intensity of the dripping sound.
    open var intensity: Double = defaultIntensity {
        willSet {
            let clampedValue = AKDrip.intensityRange.clamp(newValue)
            guard intensity != clampedValue else { return }
            internalAU?.intensity.value = AUValue(clampedValue)
        }
    }

    /// The damping factor. Maximum value is 2.0.
    open var dampingFactor: Double = defaultDampingFactor {
        willSet {
            let clampedValue = AKDrip.dampingFactorRange.clamp(newValue)
            guard dampingFactor != clampedValue else { return }
            internalAU?.dampingFactor.value = AUValue(clampedValue)
        }
    }

    /// The amount of energy to add back into the system.
    open var energyReturn: Double = defaultEnergyReturn {
        willSet {
            let clampedValue = AKDrip.energyReturnRange.clamp(newValue)
            guard energyReturn != clampedValue else { return }
            internalAU?.energyReturn.value = AUValue(clampedValue)
        }
    }

    /// Main resonant frequency.
    open var mainResonantFrequency: Double = defaultMainResonantFrequency {
        willSet {
            let clampedValue = AKDrip.mainResonantFrequencyRange.clamp(newValue)
            guard mainResonantFrequency != clampedValue else { return }
            internalAU?.mainResonantFrequency.value = AUValue(clampedValue)
        }
    }

    /// The first resonant frequency.
    open var firstResonantFrequency: Double = defaultFirstResonantFrequency {
        willSet {
            let clampedValue = AKDrip.firstResonantFrequencyRange.clamp(newValue)
            guard firstResonantFrequency != clampedValue else { return }
            internalAU?.firstResonantFrequency.value = AUValue(clampedValue)
        }
    }

    /// The second resonant frequency.
    open var secondResonantFrequency: Double = defaultSecondResonantFrequency {
        willSet {
            let clampedValue = AKDrip.secondResonantFrequencyRange.clamp(newValue)
            guard secondResonantFrequency != clampedValue else { return }
            internalAU?.secondResonantFrequency.value = AUValue(clampedValue)
        }
    }

    /// Amplitude.
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKDrip.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
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
    public init(
        intensity: Double = defaultIntensity,
        dampingFactor: Double = defaultDampingFactor,
        energyReturn: Double = defaultEnergyReturn,
        mainResonantFrequency: Double = defaultMainResonantFrequency,
        firstResonantFrequency: Double = defaultFirstResonantFrequency,
        secondResonantFrequency: Double = defaultSecondResonantFrequency,
        amplitude: Double = defaultAmplitude
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.intensity = intensity
            self.dampingFactor = dampingFactor
            self.energyReturn = energyReturn
            self.mainResonantFrequency = mainResonantFrequency
            self.firstResonantFrequency = firstResonantFrequency
            self.secondResonantFrequency = secondResonantFrequency
            self.amplitude = amplitude
        }
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

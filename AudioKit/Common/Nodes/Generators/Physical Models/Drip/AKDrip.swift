// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
open class AKDrip: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    public typealias AKAudioUnitType = AKDripAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Intensity
    public static let intensityRange: ClosedRange<AUValue> = 0 ... 100

    /// Lower and upper bounds for Damping Factor
    public static let dampingFactorRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Lower and upper bounds for Energy Return
    public static let energyReturnRange: ClosedRange<AUValue> = 0 ... 100

    /// Lower and upper bounds for Main Resonant Frequency
    public static let mainResonantFrequencyRange: ClosedRange<AUValue> = 0 ... 22_000

    /// Lower and upper bounds for First Resonant Frequency
    public static let firstResonantFrequencyRange: ClosedRange<AUValue> = 0 ... 22_000

    /// Lower and upper bounds for Second Resonant Frequency
    public static let secondResonantFrequencyRange: ClosedRange<AUValue> = 0 ... 22_000

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0 ... 1

    /// Initial value for Intensity
    public static let defaultIntensity: AUValue = 10

    /// Initial value for Damping Factor
    public static let defaultDampingFactor: AUValue = 0.2

    /// Initial value for Energy Return
    public static let defaultEnergyReturn: AUValue = 0

    /// Initial value for Main Resonant Frequency
    public static let defaultMainResonantFrequency: AUValue = 450

    /// Initial value for First Resonant Frequency
    public static let defaultFirstResonantFrequency: AUValue = 600

    /// Initial value for Second Resonant Frequency
    public static let defaultSecondResonantFrequency: AUValue = 750

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 0.3

    /// The intensity of the dripping sound.
    public let intensity = AKNodeParameter(identifier: "intensity")

    /// The damping factor. Maximum value is 2.0.
    public let dampingFactor = AKNodeParameter(identifier: "dampingFactor")

    /// The amount of energy to add back into the system.
    public let energyReturn = AKNodeParameter(identifier: "energyReturn")

    /// Main resonant frequency.
    public let mainResonantFrequency = AKNodeParameter(identifier: "mainResonantFrequency")

    /// The first resonant frequency.
    public let firstResonantFrequency = AKNodeParameter(identifier: "firstResonantFrequency")

    /// The second resonant frequency.
    public let secondResonantFrequency = AKNodeParameter(identifier: "secondResonantFrequency")

    /// Amplitude.
    public let amplitude = AKNodeParameter(identifier: "amplitude")

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
        intensity: AUValue = defaultIntensity,
        dampingFactor: AUValue = defaultDampingFactor,
        energyReturn: AUValue = defaultEnergyReturn,
        mainResonantFrequency: AUValue = defaultMainResonantFrequency,
        firstResonantFrequency: AUValue = defaultFirstResonantFrequency,
        secondResonantFrequency: AUValue = defaultSecondResonantFrequency,
        amplitude: AUValue = defaultAmplitude
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.intensity.associate(with: self.internalAU, value: intensity)
            self.dampingFactor.associate(with: self.internalAU, value: dampingFactor)
            self.energyReturn.associate(with: self.internalAU, value: energyReturn)
            self.mainResonantFrequency.associate(with: self.internalAU, value: mainResonantFrequency)
            self.firstResonantFrequency.associate(with: self.internalAU, value: firstResonantFrequency)
            self.secondResonantFrequency.associate(with: self.internalAU, value: secondResonantFrequency)
            self.amplitude.associate(with: self.internalAU, value: amplitude)
        }

    }

    // MARK: - Control

    /// Trigger the sound with an optional set of parameters
    ///
    open func trigger() {
        internalAU?.start()
        internalAU?.trigger()
    }
}

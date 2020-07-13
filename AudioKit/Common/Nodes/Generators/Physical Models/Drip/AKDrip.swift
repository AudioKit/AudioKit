// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
open class AKDrip: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    public typealias AKAudioUnitType = AKDripAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// The intensity of the dripping sound.
    @Parameter public var intensity: AUValue

    /// The damping factor. Maximum value is 2.0.
    @Parameter public var dampingFactor: AUValue

    /// The amount of energy to add back into the system.
    @Parameter public var energyReturn: AUValue

    /// Main resonant frequency.
    @Parameter public var mainResonantFrequency: AUValue

    /// The first resonant frequency.
    @Parameter public var firstResonantFrequency: AUValue

    /// The second resonant frequency.
    @Parameter public var secondResonantFrequency: AUValue

    /// Amplitude.
    @Parameter public var amplitude: AUValue

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
        intensity: AUValue = 10,
        dampingFactor: AUValue = 0.2,
        energyReturn: AUValue = 0,
        mainResonantFrequency: AUValue = 450,
        firstResonantFrequency: AUValue = 600,
        secondResonantFrequency: AUValue = 750,
        amplitude: AUValue = 0.3
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.intensity = intensity
        self.dampingFactor = dampingFactor
        self.energyReturn = energyReturn
        self.mainResonantFrequency = mainResonantFrequency
        self.firstResonantFrequency = firstResonantFrequency
        self.secondResonantFrequency = secondResonantFrequency
        self.amplitude = amplitude

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
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

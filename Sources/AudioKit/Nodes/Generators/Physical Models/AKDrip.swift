// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Physical model of the sound of dripping water. When triggered, it will
/// produce a droplet of water.
///
public class AKDrip: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "drip")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let intensityDef = AKNodeParameterDef(
        identifier: "intensity",
        name: "The intensity of the dripping sounds.",
        address: akGetParameterAddress("AKDripParameterIntensity"),
        range: 0 ... 100,
        unit: .generic,
        flags: .default)

    /// The intensity of the dripping sound.
    @Parameter public var intensity: AUValue

    public static let dampingFactorDef = AKNodeParameterDef(
        identifier: "dampingFactor",
        name: "The damping factor. Maximum value is 2.0.",
        address: akGetParameterAddress("AKDripParameterDampingFactor"),
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    /// The damping factor. Maximum value is 2.0.
    @Parameter public var dampingFactor: AUValue

    public static let energyReturnDef = AKNodeParameterDef(
        identifier: "energyReturn",
        name: "The amount of energy to add back into the system.",
        address: akGetParameterAddress("AKDripParameterEnergyReturn"),
        range: 0 ... 100,
        unit: .generic,
        flags: .default)

    /// The amount of energy to add back into the system.
    @Parameter public var energyReturn: AUValue

    public static let mainResonantFrequencyDef = AKNodeParameterDef(
        identifier: "mainResonantFrequency",
        name: "Main resonant frequency.",
        address: akGetParameterAddress("AKDripParameterMainResonantFrequency"),
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    /// Main resonant frequency.
    @Parameter public var mainResonantFrequency: AUValue

    public static let firstResonantFrequencyDef = AKNodeParameterDef(
        identifier: "firstResonantFrequency",
        name: "The first resonant frequency.",
        address: akGetParameterAddress("AKDripParameterFirstResonantFrequency"),
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    /// The first resonant frequency.
    @Parameter public var firstResonantFrequency: AUValue

    public static let secondResonantFrequencyDef = AKNodeParameterDef(
        identifier: "secondResonantFrequency",
        name: "The second resonant frequency.",
        address: akGetParameterAddress("AKDripParameterSecondResonantFrequency"),
        range: 0 ... 22_000,
        unit: .hertz,
        flags: .default)

    /// The second resonant frequency.
    @Parameter public var secondResonantFrequency: AUValue

    public static let amplitudeDef = AKNodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude.",
        address: akGetParameterAddress("AKDripParameterAmplitude"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Amplitude.
    @Parameter public var amplitude: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKDrip.intensityDef,
             AKDrip.dampingFactorDef,
             AKDrip.energyReturnDef,
             AKDrip.mainResonantFrequencyDef,
             AKDrip.firstResonantFrequencyDef,
             AKDrip.secondResonantFrequencyDef,
             AKDrip.amplitudeDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKDripDSP")
        }
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
    public func trigger() {
        internalAU?.start()
        internalAU?.trigger()
    }

    // TODO This node needs to have tests
}

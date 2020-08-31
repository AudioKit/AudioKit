// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
public class AKLowShelfParametricEqualizerFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "peq1")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let cornerFrequencyDef = AKNodeParameterDef(
        identifier: "cornerFrequency",
        name: "Corner Frequency (Hz)",
        address: akGetParameterAddress("AKLowShelfParametricEqualizerFilterParameterCornerFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Corner frequency.
    @Parameter public var cornerFrequency: AUValue

    public static let gainDef = AKNodeParameterDef(
        identifier: "gain",
        name: "Gain",
        address: akGetParameterAddress("AKLowShelfParametricEqualizerFilterParameterGain"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    @Parameter public var gain: AUValue

    public static let qDef = AKNodeParameterDef(
        identifier: "q",
        name: "Q",
        address: akGetParameterAddress("AKLowShelfParametricEqualizerFilterParameterQ"),
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    /// Q of the filter. sqrt(0.5) is no resonance.
    @Parameter public var q: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKLowShelfParametricEqualizerFilter.cornerFrequencyDef,
             AKLowShelfParametricEqualizerFilter.gainDef,
             AKLowShelfParametricEqualizerFilter.qDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKLowShelfParametricEqualizerFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cornerFrequency: Corner frequency.
    ///   - gain: Amount at which the corner frequency value shall be changed. A value of 1 is a flat response.
    ///   - q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    public init(
        _ input: AKNode? = nil,
        cornerFrequency: AUValue = 1_000,
        gain: AUValue = 1.0,
        q: AUValue = 0.707
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.cornerFrequency = cornerFrequency
        self.gain = gain
        self.q = q
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

        if let input = input {
            connections.append(input)
        }
    }
}

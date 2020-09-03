// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// A 2nd order tunable equalization filter that provides a peak/notch filter
/// for building parametric/graphic equalizers. With gain above 1, there will be
/// a peak at the center frequency with a width dependent on bandwidth. If gain
/// is less than 1, a notch is formed around the center frequency.
///
public class AKEqualizerFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "eqfl")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let centerFrequencyDef = AKNodeParameterDef(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: akGetParameterAddress("AKEqualizerFilterParameterCenterFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency. (in Hertz)
    @Parameter public var centerFrequency: AUValue

    public static let bandwidthDef = AKNodeParameterDef(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: akGetParameterAddress("AKEqualizerFilterParameterBandwidth"),
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// The peak/notch bandwidth in Hertz
    @Parameter public var bandwidth: AUValue

    public static let gainDef = AKNodeParameterDef(
        identifier: "gain",
        name: "Gain (%)",
        address: akGetParameterAddress("AKEqualizerFilterParameterGain"),
        range: -100.0 ... 100.0,
        unit: .percent,
        flags: .default)

    /// The peak/notch gain
    @Parameter public var gain: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKEqualizerFilter.centerFrequencyDef,
             AKEqualizerFilter.bandwidthDef,
             AKEqualizerFilter.gainDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKEqualizerFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: The peak/notch bandwidth in Hertz
    ///   - gain: The peak/notch gain
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = 1_000.0,
        bandwidth: AUValue = 100.0,
        gain: AUValue = 10.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
        self.gain = gain
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

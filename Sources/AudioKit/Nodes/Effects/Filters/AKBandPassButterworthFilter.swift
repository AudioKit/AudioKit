// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
public class AKBandPassButterworthFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "btbp")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let centerFrequencyDef = AKNodeParameterDef(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: akGetParameterAddress("AKBandPassButterworthFilterParameterCenterFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency. (in Hertz)
    @Parameter public var centerFrequency: AUValue

    public static let bandwidthDef = AKNodeParameterDef(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: akGetParameterAddress("AKBandPassButterworthFilterParameterBandwidth"),
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Bandwidth. (in Hertz)
    @Parameter public var bandwidth: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKBandPassButterworthFilter.centerFrequencyDef,
             AKBandPassButterworthFilter.bandwidthDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKBandPassButterworthFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: Bandwidth. (in Hertz)
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = 2_000.0,
        bandwidth: AUValue = 100.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
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

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This will digitally degrade a signal.
///
public class AKBitCrusher: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "btcr")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let bitDepthDef = AKNodeParameterDef(
        identifier: "bitDepth",
        name: "Bit Depth",
        address: akGetParameterAddress("AKBitCrusherParameterBitDepth"),
        range: 1 ... 24,
        unit: .generic,
        flags: .default)

    /// The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    @Parameter public var bitDepth: AUValue

    public static let sampleRateDef = AKNodeParameterDef(
        identifier: "sampleRate",
        name: "Sample Rate (Hz)",
        address: akGetParameterAddress("AKBitCrusherParameterSampleRate"),
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// The sample rate of signal output.
    @Parameter public var sampleRate: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKBitCrusher.bitDepthDef,
             AKBitCrusher.sampleRateDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKBitCrusherDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this bitcrusher node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK.
    ///   - sampleRate: The sample rate of signal output.
    ///
    public init(
        _ input: AKNode? = nil,
        bitDepth: AUValue = 8,
        sampleRate: AUValue = 10_000
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.bitDepth = bitDepth
        self.sampleRate = sampleRate
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

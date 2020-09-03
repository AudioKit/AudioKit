// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// An automatic wah effect, ported from Guitarix via Faust.
///
public class AKAutoWah: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "awah")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let wahDef = AKNodeParameterDef(
        identifier: "wah",
        name: "Wah Amount",
        address: akGetParameterAddress("AKAutoWahParameterWah"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Wah Amount
    @Parameter public var wah: AUValue

    public static let mixDef = AKNodeParameterDef(
        identifier: "mix",
        name: "Dry/Wet Mix",
        address: akGetParameterAddress("AKAutoWahParameterMix"),
        range: 0.0 ... 1.0,
        unit: .percent,
        flags: .default)

    /// Dry/Wet Mix
    @Parameter public var mix: AUValue

    public static let amplitudeDef = AKNodeParameterDef(
        identifier: "amplitude",
        name: "Overall level",
        address: akGetParameterAddress("AKAutoWahParameterAmplitude"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Overall level
    @Parameter public var amplitude: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKAutoWah.wahDef,
             AKAutoWah.mixDef,
             AKAutoWah.amplitudeDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKAutoWahDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this autoWah node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - wah: Wah Amount
    ///   - mix: Dry/Wet Mix
    ///   - amplitude: Overall level
    ///
    public init(
        _ input: AKNode? = nil,
        wah: AUValue = 0.0,
        mix: AUValue = 1.0,
        amplitude: AUValue = 0.1
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.wah = wah
        self.mix = mix
        self.amplitude = amplitude
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

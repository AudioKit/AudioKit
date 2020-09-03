// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Faust-based pitch shfiter
///
public class AKPitchShifter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "pshf")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let shiftDef = AKNodeParameterDef(
        identifier: "shift",
        name: "Pitch shift (in semitones)",
        address: akGetParameterAddress("AKPitchShifterParameterShift"),
        range: -24.0 ... 24.0,
        unit: .relativeSemiTones,
        flags: .default)

    /// Pitch shift (in semitones)
    @Parameter public var shift: AUValue

    public static let windowSizeDef = AKNodeParameterDef(
        identifier: "windowSize",
        name: "Window size (in samples)",
        address: akGetParameterAddress("AKPitchShifterParameterWindowSize"),
        range: 0.0 ... 10_000.0,
        unit: .hertz,
        flags: .default)

    /// Window size (in samples)
    @Parameter public var windowSize: AUValue

    public static let crossfadeDef = AKNodeParameterDef(
        identifier: "crossfade",
        name: "Crossfade (in samples)",
        address: akGetParameterAddress("AKPitchShifterParameterCrossfade"),
        range: 0.0 ... 10_000.0,
        unit: .hertz,
        flags: .default)

    /// Crossfade (in samples)
    @Parameter public var crossfade: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKPitchShifter.shiftDef,
             AKPitchShifter.windowSizeDef,
             AKPitchShifter.crossfadeDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKPitchShifterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this pitchshifter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - shift: Pitch shift (in semitones)
    ///   - windowSize: Window size (in samples)
    ///   - crossfade: Crossfade (in samples)
    ///
    public init(
        _ input: AKNode? = nil,
        shift: AUValue = 0,
        windowSize: AUValue = 1_024,
        crossfade: AUValue = 512
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.shift = shift
        self.windowSize = windowSize
        self.crossfade = crossfade
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

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This filter reiterates input with an echo density determined by
/// loopDuration. The attenuation rate is independent and is determined by
/// reverbDuration, the reverberation duration (defined as the time in seconds
/// for a signal to decay to 1/1000, or 60dB down from its original amplitude).
/// Output from a comb filter will appear only after loopDuration seconds.
///
public class AKCombFilterReverb: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "comb")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let reverbDurationDef = AKNodeParameterDef(
        identifier: "reverbDuration",
        name: "Reverb Duration (Seconds)",
        address: akGetParameterAddress("AKCombFilterReverbParameterReverbDuration"),
        range: 0.0 ... 10.0,
        unit: .seconds,
        flags: .default)

    /// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    @Parameter public var reverbDuration: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKCombFilterReverb.reverbDurationDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKCombFilterReverbDSP")
        }

        public func setLoopDuration(_ duration: AUValue) {
            akCombFilterReverbSetLoopDuration(dsp, duration)
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: The time in seconds for a signal to decay to 1/1000,
    ///     or 60dB from its original amplitude. (aka RT-60).
    ///   - loopDuration: The loop time of the filter, in seconds.
    ///     This can also be thought of as the delay time.
    ///     Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
    ///
    public init(
        _ input: AKNode? = nil,
        reverbDuration: AUValue = 1.0,
        loopDuration: AUValue = 0.1
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.reverbDuration = reverbDuration
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setLoopDuration(loopDuration)
        }

        if let input = input {
            connections.append(input)
        }
    }
}

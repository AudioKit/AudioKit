// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This filter reiterates the input with an echo density determined by loop
/// time. The attenuation rate is independent and is determined by the
/// reverberation time (defined as the time in seconds for a signal to decay to
/// 1/1000, or 60dB down from its original amplitude).  Output will begin to
/// appear immediately.
///
public class AKFlatFrequencyResponseReverb: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "alps")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let reverbDurationDef = AKNodeParameterDef(
        identifier: "reverbDuration",
        name: "Reverb Duration (Seconds)",
        address: akGetParameterAddress("AKFlatFrequencyResponseReverbParameterReverbDuration"),
        range: 0 ... 10,
        unit: .seconds,
        flags: .default)

    /// The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    @Parameter public var reverbDuration: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKFlatFrequencyResponseReverb.reverbDurationDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKFlatFrequencyResponseReverbDSP")
        }

        public func setLoopDuration(_ duration: AUValue) {
            akFlatFrequencyResponseSetLoopDuration(dsp, duration)
        }
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: Duration in seconds for signal to decay to 1/1000, or 60dB down from its original amplitude.
    ///   - loopDuration: Loop duration of the filter, in seconds.
    ///     This can also be thought of as the delay time or “echo density” of the reverberation.
    ///
    public init(
        _ input: AKNode? = nil,
        reverbDuration: AUValue = 0.5,
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

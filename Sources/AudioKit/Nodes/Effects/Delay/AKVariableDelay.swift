// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// A delay line with cubic interpolation.
///
public class AKVariableDelay: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "vdla")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let timeDef = AKNodeParameterDef(
        identifier: "time",
        name: "Delay time (Seconds)",
        address: akGetParameterAddress("AKVariableDelayParameterTime"),
        range: 0 ... 10,
        unit: .seconds,
        flags: .default)

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @Parameter public var time: AUValue

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("AKVariableDelayParameterFeedback"),
        range: 0 ... 1,
        unit: .generic,
        flags: .default)

    /// Feedback amount. Should be a value between 0-1.
    @Parameter public var feedback: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKVariableDelay.timeDef,
             AKVariableDelay.feedbackDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKVariableDelayDSP")
        }

        public func setMaximumTime(_ maximumTime: AUValue) {
            akVariableDelaySetMaximumTime(dsp, maximumTime)
        }
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: AKNode? = nil,
        time: AUValue = 0,
        feedback: AUValue = 0,
        maximumTime: AUValue = 5
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.time = time
        self.feedback = feedback
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.internalAU?.setMaximumTime(maximumTime)
        }

        if let input = input {
            connections.append(input)
        }
    }
}

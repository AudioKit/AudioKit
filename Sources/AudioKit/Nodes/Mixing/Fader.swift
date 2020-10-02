// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Stereo Fader.
public class Fader: Node, AudioUnitContainer, Tappable, Toggleable {
    /// Unique four-letter identifier "fder"
    public static let ComponentDescription = AudioComponentDescription(effect: "fder")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = InternalAU

    /// Internal audio unit
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Amplification Factor, from 0 ... 4
    open var gain: AUValue = 1 {
        willSet {
            leftGain = gain
            rightGain = gain
        }
    }

    /// Allow gain to be any non-negative number
    public static let gainRange: ClosedRange<AUValue> = 0.0 ... Float.greatestFiniteMagnitude

    /// Specification details for left gain
    public static let leftGainDef = NodeParameterDef(
        identifier: "leftGain",
        name: "Left Gain",
        address: akGetParameterAddress("FaderParameterLeftGain"),
        range: Fader.gainRange,
        unit: .linearGain,
        flags: .default)

    /// Left Channel Amplification Factor
    @Parameter public var leftGain: AUValue

    /// Specification details for right gain
    public static let rightGainDef = NodeParameterDef(
        identifier: "rightGain",
        name: "Right Gain",
        address: akGetParameterAddress("FaderParameterRightGain"),
        range: Fader.gainRange,
        unit: .linearGain,
        flags: .default)

    /// Right Channel Amplification Factor
    @Parameter public var rightGain: AUValue

    /// Amplification Factor in db
    public var dB: AUValue {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    /// Whether or not to flip left and right channels
    public static let flipStereoDef = NodeParameterDef(
        identifier: "flipStereo",
        name: "Flip Stereo",
        address: akGetParameterAddress("FaderParameterFlipStereo"),
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    /// Flip left and right signal
    @Parameter public var flipStereo: Bool

    /// Specification for whether to mix the stereo signal down to mono
    public static let mixToMonoDef = NodeParameterDef(
        identifier: "mixToMono",
        name: "Mix To Mono",
        address: akGetParameterAddress("FaderParameterMixToMono"),
        range: 0.0 ... 1.0,
        unit: .boolean,
        flags: .default)

    /// Make the output on left and right both be the same combination of incoming left and mixed equally
    @Parameter public var mixToMono: Bool

    // MARK: - Audio Unit

    /// Internal audio unit for fader
    public class InternalAU: AudioUnitBase {
        /// Get an array of the parameter definitions
        /// - Returns: Array of parameter definitions
        public override func getParameterDefs() -> [NodeParameterDef] {
            [Fader.leftGainDef,
             Fader.rightGainDef,
             Fader.flipStereoDef,
             Fader.mixToMonoDef]
        }

        /// Create the DSP Refence for this node
        /// - Returns: DSP Reference
        public override func createDSP() -> DSPRef {
            akCreateDSP("FaderDSP")
        }
    }
    // MARK: - Initialization

    /// Initialize this fader node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(_ input: Node, gain: AUValue = 1) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType

            self.leftGain = gain
            self.rightGain = gain
            self.flipStereo = false
            self.mixToMono = false
        }

        connections.append(input)
    }

    deinit {
        Log("* { Fader }")
    }

    // MARK: - Automation

    /// Gain automation helper
    /// - Parameters:
    ///   - events: List of events
    ///   - startTime: start time
    public func automateGain(events: [AutomationEvent], startTime: AVAudioTime? = nil) {
        $leftGain.automate(events: events, startTime: startTime)
        $rightGain.automate(events: events, startTime: startTime)
    }

    /// Stop automation
    public func stopAutomation() {
        $leftGain.stopAutomation()
        $rightGain.stopAutomation()
    }
}

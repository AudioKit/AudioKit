// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AKStringResonator passes the input through a network composed of comb,
/// low-pass and all-pass filters, similar to the one used in some versions of
/// the Karplus-Strong algorithm, creating a string resonator effect. The
/// fundamental frequency of the “string” is controlled by the
/// fundamentalFrequency.  This operation can be used to simulate sympathetic
/// resonances to an input signal.
///
public class AKStringResonator: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "stre")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let fundamentalFrequencyDef = AKNodeParameterDef(
        identifier: "fundamentalFrequency",
        name: "Fundamental Frequency (Hz)",
        address: akGetParameterAddress("AKStringResonatorParameterFundamentalFrequency"),
        range: 12.0 ... 10_000.0,
        unit: .hertz,
        flags: .default)

    /// Fundamental frequency of string.
    @Parameter public var fundamentalFrequency: AUValue

    public static let feedbackDef = AKNodeParameterDef(
        identifier: "feedback",
        name: "Feedback (%)",
        address: akGetParameterAddress("AKStringResonatorParameterFeedback"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance.
    /// Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.

    @Parameter public var feedback: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKStringResonator.fundamentalFrequencyDef,
             AKStringResonator.feedbackDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKStringResonatorDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - fundamentalFrequency: Fundamental frequency of string.
    ///   - feedback: Feedback amount (value between 0-1).
    ///   A value close to 1 creates a slower decay and a more pronounced resonance.
    ///   Small values may leave input signal unaffected. Depending on the filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode? = nil,
        fundamentalFrequency: AUValue = 100,
        feedback: AUValue = 0.95
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.fundamentalFrequency = fundamentalFrequency
        self.feedback = feedback
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

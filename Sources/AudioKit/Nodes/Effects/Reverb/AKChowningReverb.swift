// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// This is was built using the JC reverb implentation found in FAUST. According
/// to the source code, the specifications for this implementation were found on
/// an old SAIL DART backup tape.
/// This class is derived from the CLM JCRev function, which is based on the use
/// of networks of simple allpass and comb delay filters.  This class implements
/// three series allpass units, followed by four parallel comb filters, and two
/// decorrelation delay lines in parallel at the output.
///
public class AKChowningReverb: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(effect: "jcrv")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - Parameters

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {
        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKChowningReverbDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///
    public init(
        _ input: AKNode? = nil
        ) {
        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType        }

        if let input = input {
            connections.append(input)
        }
    }
}

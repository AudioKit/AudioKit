// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public class TapNode: Node, AudioUnitContainer, Toggleable, Tappable {

    public typealias AudioUnitType = InternalAU

    public static let ComponentDescription = AudioComponentDescription(effect: "tpnd")

    public private(set) var internalAU: AudioUnitType?

//    public var leftBuffer: UnsafeMutablePointer<TPCircularBuffer> {
//        akGetLeftBuffer(internalAU?.dsp)
//    }
//    public var rightBuffer: UnsafeMutablePointer<TPCircularBuffer> {
//        akGetRightBuffer(internalAU?.dsp)
//    }

    // MARK: - Audio Unit

    public class InternalAU: AudioUnitBase {
        public override func createDSP() -> DSPRef {
            akCreateDSP("TapNodeDSP")
        }
    }
    // MARK: - Initialization

    /// Initialize this tap node
    ///
    /// - Parameters:
    ///   - input: Node whose output will be amplified
    ///
    public init(_ input: Node) { // Perhaps a callback here?
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AudioUnitType
        }

        connections.append(input)
    }

}

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit
import TPCircularBuffer

public class TapNode: Node, AudioUnitContainer, Toggleable {

    public typealias AudioUnitType = InternalAU

    public static let ComponentDescription = AudioComponentDescription(effect: "tpnd")

    public private(set) var internalAU: AudioUnitType?

    public var leftBuffer: TPCircularBuffer? {
        internalAU?.leftBuffer
    }
    public var rightBuffer: TPCircularBuffer? {
        internalAU?.rightBuffer
    }

    // MARK: - Audio Unit

    public class InternalAU: AudioUnitBase {
        public override func createDSP() -> DSPRef {
            akCreateDSP("TapNodeDSP")
        }

        var leftBuffer: TPCircularBuffer {
            akTapNodeGetLeftBuffer(dsp)
        }
        var rightBuffer: TPCircularBuffer {
            akTapNodeGetRightBuffer(dsp)
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

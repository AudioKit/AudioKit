// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

/// STK Flute
///
public class AKFlute: AKNode, AKToggleable, AKComponent {

    public static let ComponentDescription = AudioComponentDescription(instrument: "flut")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public class InternalAU: AKAudioUnitBase {

        public override func createDSP() -> AKDSPRef {
            return akCreateDSP("AKFluteDSP")
        }

        public func trigger(note: UInt8, amplitude: AUValue) {

            if let midiBlock = scheduleMIDIEventBlock {
                let event = AKMIDIEvent(noteOn: note,
                                        velocity: UInt8(amplitude * 127.0),
                                        channel: 0)
                event.data.withUnsafeBufferPointer { ptr in
                    guard let ptr = ptr.baseAddress else { return }
                    midiBlock(AUEventSampleTimeImmediate, 0, event.data.count, ptr)
                }
            }

        }
    }

    // MARK: - Initialization

    /// Initialize the STK Flute model
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is
    ///                greater than that.
    ///   - amplitude: Amplitude
    ///
    public init() {
        super.init(avAudioNode: AVAudioNode())
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }
    }

    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - frequency: Frequency in Hz
    ///   - amplitude: Volume
    ///
    public func trigger(note: UInt8, amplitude: AUValue = 1) {
        internalAU?.start()
        internalAU?.trigger(note: note, amplitude: amplitude)
    }

}

#endif

// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI

/**
 Allows a MIDIPacket to be iterated through with a for statement.
 This is necessary because MIDIPacket can contain multiple midi events,
 but Swift makes this unnecessarily hard because the MIDIPacket struct uses a tuple
 for the data field. Grrr!

 Example usage:
 let packet: MIDIPacket
 for message in packet {
 // message is a Message
 }
 */
extension MIDIPacket: Sequence {
    /// Generate a MIDI packet
    public func makeIterator() -> AnyIterator<AKMIDIEvent> {
        let generator = generatorForTuple(self.data)
        var index: UInt16 = 0

        return AnyIterator {
            if index >= self.length {
                return nil
            }

            func pop() -> MIDIByte {
                assert((index < self.length) || (index <= self.length && self.data.0 != AKMIDISystemCommand.sysEx.byte))
                index += 1
                // Note: getting rid of the as! but saying 0 as default might not be desired.
                return generator.next() as? MIDIByte ?? 0
            }
            let status = pop()
            if AKMIDI.sharedInstance.isReceivingSysEx {
                return AKMIDIEvent.appendIncomingSysEx(packet: self) //will be nil until sysex is done
            } else if var mstat = AKMIDIStatusType.from(byte: status) {
                var data1: MIDIByte = 0
                var data2: MIDIByte = 0

                switch  mstat {

                case .noteOff, .noteOn, .polyphonicAftertouch, .controllerChange, .pitchWheel:
                    data1 = pop(); data2 = pop()
                    if mstat == .noteOn && data2 == 0 {
                        // turn noteOn with velocity 0 to noteOff
                        mstat = .noteOff
                    }
                    return AKMIDIEvent(data: [status, data1, data2])

                case .programChange, .channelAftertouch:
                    data1 = pop()
                    return AKMIDIEvent(data: [status, data1])
                }
            } else if let command = AKMIDISystemCommand(rawValue: status) {
                var data1: MIDIByte = 0
                var data2: MIDIByte = 0
                switch command {
                case .sysEx:
                    index = self.length
                    return AKMIDIEvent(packet: self)
                case .songPosition:
                    //the remaining event generators need to be tested and tweaked to the specific messages
                    data1 = pop()
                    data2 = pop()
                    return AKMIDIEvent(data: [status, data1, data2])
                case .timeCodeQuarterFrame:
                    data1 = pop()
                    return AKMIDIEvent(data: [status, data1])
                case .songSelect:
                    data1 = pop()
                    return AKMIDIEvent(data: [status, data1])
                default:
                    return AKMIDIEvent(packet: self)
                }
            } else {
                return nil
            }
        }
    }
}

typealias AKRawMIDIPacket = (
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte,
    MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte, MIDIByte)

/// The returned generator will enumerate each value of the provided tuple.
func generatorForTuple(_ tuple: AKRawMIDIPacket) -> AnyIterator<Any> {
    let children = Mirror(reflecting: tuple).children
    return AnyIterator(children.makeIterator().lazy.map { $0.value }.makeIterator())
}
#endif

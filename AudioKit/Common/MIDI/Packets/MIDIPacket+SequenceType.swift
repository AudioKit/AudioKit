//
//  MIDIPacket+SequenceType.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 4/29/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

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
extension MIDIPacket: SequenceType {
    /// Generate a midi packet
    public func generate() -> AnyGenerator<AKMIDIEvent> {
        let generator = generatorForTuple(self.data)
        var index: UInt16 = 0
        
        return AnyGenerator {
            if index >= self.length {
                return nil
            }
            
            func pop() -> UInt8 {
                assert(index < self.length)
                index += 1
                return generator.next() as! UInt8
            }
            
            let status = pop()
            if AKMIDIEvent.isStatusByte(status) {
                var data1: UInt8 = 0
                var data2: UInt8 = 0
                var mstat = AKMIDIEvent.statusFromValue(status)
                switch  mstat {
                case .NoteOff,
                .NoteOn,
                .PolyphonicAftertouch,
                .ControllerChange,
                .PitchWheel:
                    data1 = pop(); data2 = pop()
                    
                case .ProgramChange,
                .ChannelAftertouch:
                    data1 = pop()
                    
                case .SystemCommand: break
                }
                
                if mstat == .NoteOn && data2 == 0 {
                    // turn noteOn with velocity 0 to noteOff
                    mstat = .NoteOff
                }
                
                let chan = (status & 0xF)
                return AKMIDIEvent(status: mstat, channel: chan, byte1: data1, byte2: data2)
            } else if status == 0xF0 {
                // sysex - guaranteed by coremidi to be the entire packet
                index = self.length
                return AKMIDIEvent(packet: self)
            } else {
                let cmd = AKMIDISystemCommand(rawValue: status)!
                var data1: UInt8 = 0
                var data2: UInt8 = 0
                switch  cmd {
                case .Sysex: break
                case .SongPosition:
                    data1 = pop()
                    data2 = pop()
                case .SongSelect:
                    data1 = pop()
                default: break
                }
                
                return AKMIDIEvent(command: cmd, byte1: data1, byte2: data2)
            }
        }
    }
}


/// Temporary hack for Xcode 7.3.1 - Appreciate improvements to this if you want to make a go of it!
typealias AKRawMIDIPacket = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)


/// The returned generator will enumerate each value of the provided tuple.
func generatorForTuple(tuple: AKRawMIDIPacket) -> AnyGenerator<Any> {
    let children = Mirror(reflecting: tuple).children
    return AnyGenerator(children.generate().lazy.map { $0.value }.generate())
}
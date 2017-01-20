//
//  MIDIPacket+SequenceType.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
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
extension MIDIPacket: Sequence {
    /// Generate a midi packet
    public func makeIterator() -> AnyIterator<AKMIDIEvent> {
        let generator = generatorForTuple(self.data)
        var index: UInt16 = 0
        
        return AnyIterator {
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
                
                let chan = status & 0xF
                
                switch  mstat {
                    
                case .noteOff, .noteOn, .polyphonicAftertouch, .controllerChange, .pitchWheel:
                    data1 = pop(); data2 = pop()
                    
                    if mstat == .noteOn && data2 == 0 {
                        // turn noteOn with velocity 0 to noteOff
                        mstat = .noteOff
                    }
                    return AKMIDIEvent(status: mstat, channel: chan, byte1: data1, byte2: data2)
                    
                case .programChange, .channelAftertouch:
                    data1 = pop()
                    return AKMIDIEvent(status: mstat, channel: chan, byte1: data1, byte2: data2)
                    
                case .systemCommand:
                    let cmd = AKMIDISystemCommand(rawValue: status)!
                    switch  cmd {
                    case .sysex:
                        // sysex - guaranteed by coremidi to be the entire packet
                        index = self.length
                        return AKMIDIEvent(packet: self)
                    case .songPosition:
                        //the remaining event generators need to be tested and tweaked to the specific messages
                        data1 = pop()
                        data2 = pop()
                        
                        return AKMIDIEvent(command: cmd, byte1: data1, byte2: data2)
                    case .songSelect:
                        data1 = pop()
                
                        return AKMIDIEvent(command: cmd, byte1: data1, byte2: data2)
                    default:
                        return AKMIDIEvent(packet: self)
                    }
                    
                default:
                    return AKMIDIEvent(packet: self)
                }
            } else {
                return nil
            }
        }
    }
}


/// Temporary hack for Xcode 7.3.1 - Appreciate improvements to this if you want to make a go of it!
typealias AKRawMIDIPacket = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)


/// The returned generator will enumerate each value of the provided tuple.
func generatorForTuple(_ tuple: AKRawMIDIPacket) -> AnyIterator<Any> {
    let children = Mirror(reflecting: tuple).children
    return AnyIterator(children.makeIterator().lazy.map { $0.value }.makeIterator())
}

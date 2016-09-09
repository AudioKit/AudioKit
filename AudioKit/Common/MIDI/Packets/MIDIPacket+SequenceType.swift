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
                
                switch  mstat {
                    
                case .noteOff, .noteOn, .polyphonicAftertouch, .controllerChange, .pitchWheel:
                    data1 = pop(); data2 = pop()
                    
                case .programChange, .channelAftertouch:
                    data1 = pop()
                    
                case .systemCommand:
                    break
                }
                
                if mstat == .noteOn && data2 == 0 {
                    // turn noteOn with velocity 0 to noteOff
                    mstat = .noteOff
                }
                
                let chan = status & 0xF
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
                    
                case .sysex:
                    break
                    
                case .songPosition:
                    data1 = pop()
                    data2 = pop()
                    
                case .songSelect:
                    data1 = pop()
                    
                default:
                    break
                }
                
                return AKMIDIEvent(command: cmd, byte1: data1, byte2: data2)
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

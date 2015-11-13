//
//  AKMidiEvent.swift
//  AudioKit
//
//  Created by Jeff Cooper on 11/10/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import CoreMIDI

enum AKMidiStatus :Int {
    case AKMidiStatusNoteOff = 8
    case AKMidiStatusNoteOn = 9
    case AKMidiStatusPolyphonicAftertouch = 10
    case AKMidiStatusControllerChange = 11
    case AKMidiStatusProgramChange = 12
    case AKMidiStatusChannelAftertouch = 13
    case AKMidiStatusPitchWheel = 14
    case AKMidiStatusSystemCommand = 15
}

enum AKMidiSystemCommand : UInt8{
    case AKMidiCommandNone = 0
    case AKMidiCommandSysex = 240
    case AKMidiCommandSongPosition = 242
    case AKMidiCommandSongSelect = 243
    case AKMidiCommandTuneRequest = 246
    case AKMidiCommandSysexEnd = 247
    case AKMidiCommandClock = 248
    case AKMidiCommandStart = 250
    case AKMidiCommandContinue = 251
    case AKMidiCommandStop = 252
    case AKMidiCommandActiveSensing = 254
    case AKMidiCommandSysReset = 255
}

/// Value of byte 2 in conjunction with AKMidiStatusControllerChange
enum AKMidiControl : UInt8
    {
    case AKMidiControlCC0 = 0
    case AKMidiControlModulationWheel = 1
    case AKMidiControlBreathControl = 2
    case AKMidiControlCC3 = 3
    case AKMidiControlFootControl = 4
    case AKMidiControlPortamento = 5
    case AKMidiControlDataEntry = 6
    case AKMidiControlMainVolume = 7
    case AKMidiControlBalance = 8
    case AKMidiControlCC9 = 9
    case AKMidiControlPan = 10
    case AKMidiControlExpression = 11
    case AKMidiControlCC12 = 12
    case AKMidiControlCC13 = 13
    case AKMidiControlCC14 = 14
    case AKMidiControlCC15 = 15
    case AKMidiControlCC16 = 16
    case AKMidiControlCC17 = 17
    case AKMidiControlCC18 = 18
    case AKMidiControlCC19 = 19
    case AKMidiControlCC20 = 20
    case AKMidiControlCC21 = 21
    case AKMidiControlCC22 = 22
    case AKMidiControlCC23 = 23
    case AKMidiControlCC24 = 24
    case AKMidiControlCC25 = 25
    case AKMidiControlCC26 = 26
    case AKMidiControlCC27 = 27
    case AKMidiControlCC28 = 28
    case AKMidiControlCC29 = 29
    case AKMidiControlCC30 = 30
    case AKMidiControlCC31 = 31
        
    case AKMidiControlLSB = 32 // Combine with above constants to get the LSB
        
    case AKMidiControlDamperOnOff = 64
    case AKMidiControlPortamentoOnOff = 65
    case AKMidiControlSustenutoOnOff = 66
    case AKMidiControlSoftPedalOnOff = 67
        
    case AKMidiControlDataEntryPlus = 96
    case AKMidiControlDataEntryMinus = 97
        
    case AKMidiControlLocalControlOnOff = 122
    case AKMidiControlAllNotesOff = 123
}

enum AKMidiNotification : String{
    case AKMidiNoteOnNotification = "AKMidiNoteOn"
    case AKMidiNoteOffNotification = "AKMidiNoteOff"
    case AKMidiPolyphonicAftertouchNotification = "AKMidiPolyphonicAftertouch"
    case AKMidiProgramChangeNotification = "AKMidiProgramChange"
    case AKMidiAftertouchNotification = "AKMidiAftertouch"
    case AKMidiPitchWheelNotification = "AKMidiPitchWheel"
    case AKMidiControllerNotification = "AKMidiController"
    case AKMidiModulationNotification = "AKMidiModulation"
    case AKMidiPortamentoNotification = "AKMidiPortamento"
    case AKMidiVolumeNotification = "AKMidiVolume"
    case AKMidiBalanceNotification = "AKMidiBalance"
    case AKMidiPanNotification = "AKMidiPan"
    case AKMidiExpressionNotification = "AKMidiExpression"
    case AKMidiControlNotification = "AKMidiControl"
}
/*
You add observes like this:
defaultCenter.addObserverForName(AKMidiNotification, object: nil, queue: mainQueue, usingBlock: YourNotifFunction)

YourNotifFunction takes an NSNotifcation as an argument, 
and then all the good stuff is contained in the userInfo part of the notification

an example, calling a function called 'midiNotif':
defaultCenter.addObserverForName("AKMidiControl", object: nil, queue: mainQueue, usingBlock: myNotifFunction)

func myNotifFunction(notif:NSNotification){
    print(notif.userInfo)
}
*/

public class AKMidiEvent : NSObject{
    var _data=[UInt8](count: 3, repeatedValue: 0)
    var length:UInt8? // The length in bytes for this MIDI message (1 to 3 bytes)
    
    var status:AKMidiStatus{
        let status = _data[0] >> 4
        return AKMidiStatus(rawValue: Int(status))!
    }
    var command:AKMidiSystemCommand{
        let status = (_data[0] >> 4)
        if(status < 15){
            return .AKMidiCommandNone
        }
        return AKMidiSystemCommand(rawValue:_data[0])!
    }
    var channel:UInt8{
        let status = (_data[0] >> 4)
        if (status < 15){
            return (_data[0] & 0xF) + 1;
        }
        return 0
    }
    var data1:UInt8{
        return _data[1]
    }
    var data2:UInt8{
        return _data[2]
    }
    var data:UInt16{
        let x = UInt16(_data[1])
        let y = UInt16(_data[2] << 7)
        return y + x
        //return (_data[2] << 7) | _data[1]
    }
    
    var bytes:NSData{
        return NSData(bytes: [_data[0], _data[1], _data[2]] as [UInt8], length: 3)
    }
    
    static func initWithMIDIPacket(packet:MIDIPacket)->AKMidiEvent{
        if (packet.data.0 < 0xF0){
            let status = Int(packet.data.0) >> 4
            let channel = UInt8(packet.data.0 & 0xF)+1
            return initWithStatus(AKMidiStatus(rawValue: status)!,
                channel: channel,
                d1: packet.data.1,
                d2: packet.data.2)
        }else{
            return initWithSystemCommand(AKMidiSystemCommand(rawValue: packet.data.0)!,
                d1: packet.data.1,
                d2: packet.data.2)
        }
    }//end initWithMIDIPacket
    
    static func initWithStatus(status:AKMidiStatus, channel:UInt8, d1:UInt8, d2:UInt8)->AKMidiEvent{
        let midiEvent = AKMidiEvent()
        midiEvent._data[0] = UInt8(status.rawValue << 4) | UInt8((channel-1) & 0xf);
        midiEvent._data[1] = d1 & 0x7F;
        midiEvent._data[2] = d2 & 0x7F;
        
        switch status {
            case .AKMidiStatusControllerChange:
                if (d1 < AKMidiControl.AKMidiControlDataEntryPlus.rawValue
                    || d1 == AKMidiControl.AKMidiControlLocalControlOnOff.rawValue) {
                    midiEvent.length = 3
                }
                else {
                    midiEvent.length = 2
                }
            case .AKMidiStatusChannelAftertouch: break
            case .AKMidiStatusProgramChange:
                midiEvent.length = 2
            default:
                midiEvent.length = 3
            }
        return midiEvent
    }//end initWithStatus
    
    static func initWithSystemCommand(command:AKMidiSystemCommand, d1:UInt8, d2:UInt8)->AKMidiEvent{
        let midiEvent = AKMidiEvent()
        midiEvent._data[0] = command.rawValue
        switch command{
        case .AKMidiCommandSysex: break
        case .AKMidiCommandSongPosition:
            midiEvent._data[1] = d1 & 0x7F;
            midiEvent._data[2] = d2 & 0x7F;
            midiEvent.length = 3;
            break
        case .AKMidiCommandSongSelect:
            midiEvent._data[1] = d1 & 0x7F;
            midiEvent.length = 2;
            break;
        default:
            midiEvent.length = 1
            break
        }
        return midiEvent
    }//end initWithSystemCommand
    
    func postNotification()->Bool{
        var ret = NSDictionary()
        var name = String()
        switch status{
        case .AKMidiStatusNoteOn:
            ret = ["note":NSInteger(data1),
                "velocity":NSInteger(data2),
                "channel":NSInteger(channel)]
            name = String(AKMidiNotification.AKMidiNoteOnNotification.rawValue);
            break
        case .AKMidiStatusNoteOff:
            ret = ["note":NSInteger(data1),
                "velocity":NSInteger(data2),
                "channel":NSInteger(channel)]
            name = String(AKMidiNotification.AKMidiNoteOffNotification.rawValue);
            break
        case .AKMidiStatusPolyphonicAftertouch:
            ret = ["note":NSInteger(data1),
                "pressure":NSInteger(data2),
                "channel":NSInteger(channel)]
            name = String(AKMidiNotification.AKMidiPolyphonicAftertouchNotification.rawValue);
            break
        case .AKMidiStatusChannelAftertouch:
            ret = ["pressure":NSInteger(data1),
                "channel":NSInteger(channel)]
            name = String(AKMidiNotification.AKMidiAftertouchNotification.rawValue);
            break
        case .AKMidiStatusPitchWheel:
            ret = ["pitchWheel":NSInteger(data),
                "channel":NSInteger(channel)]
            name = String(AKMidiNotification.AKMidiPitchWheelNotification.rawValue);
            break
        case .AKMidiStatusProgramChange:
            ret = ["pressure":NSInteger(data1),
                "channel":NSInteger(channel)]
            name = String(AKMidiNotification.AKMidiProgramChangeNotification.rawValue);
            break
        case .AKMidiStatusControllerChange:
            switch(data1) {
                case AKMidiControl.AKMidiControlModulationWheel.rawValue:
                    name = String(AKMidiNotification.AKMidiModulationNotification.rawValue)
                    break
                case AKMidiControl.AKMidiControlPortamento.rawValue:
                    name = String(AKMidiNotification.AKMidiPortamentoNotification.rawValue)
                    break
                case AKMidiControl.AKMidiControlMainVolume.rawValue:
                    name = String(AKMidiNotification.AKMidiVolumeNotification.rawValue)
                    break
                case AKMidiControl.AKMidiControlBalance.rawValue:
                    name = String(AKMidiNotification.AKMidiBalanceNotification.rawValue)
                    break
                case AKMidiControl.AKMidiControlPan.rawValue:
                    name = String(AKMidiNotification.AKMidiPanNotification.rawValue)
                    break
                case AKMidiControl.AKMidiControlExpression.rawValue:
                    name = String(AKMidiNotification.AKMidiExpressionNotification.rawValue)
                    break
                default: // Catch-all
                    name = String(AKMidiNotification.AKMidiControlNotification.rawValue)
                    break
            }
            ret = ["controller":NSInteger(data1),
                "value":NSInteger(data2),
                "channel":NSInteger(channel)]
            break
        case .AKMidiStatusSystemCommand:
            switch (self.command) {
                case .AKMidiCommandClock:
                    print("MIDI Clock")
                    break
                case .AKMidiCommandSysex:
                    print("SysEx Command")
                    break
                case .AKMidiCommandSysexEnd:
                    print("SysEx EOX")
                    break
                case .AKMidiCommandSysReset:
                    print("MIDI System Reset")
                    break
                default:
                    break
            }
            break
        }
        if (ret.count != 0) {
            NSNotificationCenter.defaultCenter().postNotificationName(name,
                object: self,
                userInfo: ret as [NSObject : AnyObject])
            return true;
        }
        return false;

    }//end postNotification
    
//#pragma mark - Utility constructors for common MIDI events
    static func eventWithNoteOn(note:UInt8, channel:UInt8, velocity:UInt8)->AKMidiEvent{
        return AKMidiEvent.initWithStatus(.AKMidiStatusNoteOn, channel: channel, d1: note, d2: velocity)
    }
    static func eventWithNoteOff(note:UInt8, channel:UInt8, velocity:UInt8)->AKMidiEvent{
        return AKMidiEvent.initWithStatus(.AKMidiStatusNoteOff, channel: channel, d1: note, d2: velocity)
    }
    static func eventWithProgramChange(program:UInt8, channel:UInt8)->AKMidiEvent{
        return AKMidiEvent.initWithStatus(.AKMidiStatusProgramChange, channel: channel, d1: program, d2: 0)
    }

}//end akmidievent
/*
- (NSString *)description {
NSMutableString *ret = [NSMutableString stringWithString:@"<MIDI:"];
for (int i = 0; i < self.length; i++) {
[ret appendFormat:@" %02X",_data[i]];
}
[ret appendString:@">"];
return ret;
}


*/
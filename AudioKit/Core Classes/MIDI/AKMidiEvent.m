//
//  AKMidiEvent.m
//  AudioKit
//
//  Created by Stéphane Peter on 7/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import "AKMidiEvent.h"
#import <CoreMIDI/CoreMIDI.h>

@implementation AKMidiEvent {
    UInt8 _data[3];
    UInt8 _len; // The actual length of the message (1 to 3 bytes)
}

- (instancetype)initWithStatus:(AKMidiConstant)status channel:(UInt8)channel data1:(UInt8)d1 data2:(UInt8)d2
{
    self = [super init];
    if (self) {
        _data[0] = (status << 4) | (channel & 0xf);
        _data[1] = d1 & 0x7F;
        _data[2] = d2 & 0x7F;
        switch(status) {
            case AKMidiConstantControllerChange:
                if (d1 < 96 || d1 == 122)
                    _len = 3;
                else
                    _len = 2;
                break;
            case AKMidiConstantChannelAftertouch:
            case AKMidiConstantProgramChange:
                _len = 2;
                break;
            default:
                _len = 3;
                break;
        }
    }
    return self;
}

- (instancetype)initWithSystemCommand:(AKMidiSystemCommand)command data1:(UInt8)d1 data2:(UInt8)d2
{
    self = [super init];
    if (self) {
        _data[0] = command;
        switch(command) {
            case AKMidiCommandSysex:
            case AKMidiCommandSongPosition:
                _data[1] = d1 & 0x7F;
                _data[2] = d2 & 0x7F;
                _len = 3;
                break;
            case AKMidiCommandSongSelect:
                _data[1] = d1 & 0x7F;
                _len = 2;
                break;
            default: // All other commands don't require a parameter or are undefined
                _len = 1;
                break;
        }
    }
    return self;
}

- (instancetype)initWithMIDIPacket:(MIDIPacket *)packet
{
    self = [super init];
    if (self) {
        NSAssert(packet->length <= sizeof(_data), @"Memory overrun, packet too long");
        memcpy(_data, packet->data, packet->length);
        _len = packet->length;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        [data getBytes:_data length:sizeof(_data)];
        _len = (data.length > sizeof(_data)) ? sizeof(_data) : data.length;
    }
    return self;
}

+ (instancetype)midiEventFromPacket:(MIDIPacket *)packet
{
    return [[AKMidiEvent alloc] initWithMIDIPacket:packet];
}


- (AKMidiConstant)status
{
    return _data[0] >> 4;
}

- (AKMidiSystemCommand)command
{
    if ((_data[0] >> 4) < 15) {
        return AKMidiCommandNone;
    }
    return _data[0];
}

- (UInt8)channel
{
    if ((_data[0] >> 4) < 15) {
        return _data[0] & 0xF;
    }
    return 0; // Other system message
}

- (UInt8)data1 {
    return _data[1];
}

- (UInt8)data2 {
    return _data[2];
}

- (UInt16)data {
    return (_data[2] << 7) | _data[1];
}

- (NSData *)bytes {
    return [NSData dataWithBytes:_data length:_len];
}

- (NSString *)description {
    NSMutableString *ret = [NSMutableString stringWithString:@"<MIDI:"];
    for (int i = 0; i < _len; i++) {
        [ret appendFormat:@" %02X",_data[i]];
    }
    [ret appendString:@">"];
    return ret;
}

@end

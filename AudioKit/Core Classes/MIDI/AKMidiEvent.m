//
//  AKMidiEvent.m
//  AudioKit
//
//  Created by Stéphane Peter on 7/22/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import "AKMidiEvent.h"
#import <CoreMIDI/CoreMIDI.h>

NSString * const AKMidiNoteOnNotification               = @"AKMidiNoteOn";
NSString * const AKMidiNoteOffNotification              = @"AKMidiNoteOff";
NSString * const AKMidiPolyphonicAftertouchNotification = @"AKMidiPolyphonicAftertouch";
NSString * const AKMidiProgramChangeNotification        = @"AKMidiProgramChange";
NSString * const AKMidiAftertouchNotification           = @"AKMidiAftertouch";
NSString * const AKMidiPitchWheelNotification           = @"AKMidiPitchWheel";
NSString * const AKMidiControllerNotification           = @"AKMidiController";
NSString * const AKMidiModulationNotification           = @"AKMidiModulation";
NSString * const AKMidiPortamentoNotification           = @"AKMidiPortamento";
NSString * const AKMidiVolumeNotification               = @"AKMidiVolume";
NSString * const AKMidiBalanceNotification              = @"AKMidiBalance";
NSString * const AKMidiPanNotification                  = @"AKMidiPan";
NSString * const AKMidiExpressionNotification           = @"AKMidiExpression";
NSString * const AKMidiControlNotification              = @"AKMidiControl";

@implementation AKMidiEvent {
    UInt8 _data[3];
}

- (instancetype)initWithStatus:(AKMidiStatus)status channel:(UInt8)channel data1:(UInt8)d1 data2:(UInt8)d2
{
    self = [super init];
    if (self) {
        _data[0] = (status << 4) | ((channel-1) & 0xf);
        _data[1] = d1 & 0x7F;
        _data[2] = d2 & 0x7F;
        switch(status) {
            case AKMidiStatusControllerChange:
                if (d1 < AKMidiControlDataEntryPlus || d1 == AKMidiControlLocalControlOnOff)
                    _length = 3;
                else
                    _length = 2;
                break;
            case AKMidiStatusChannelAftertouch:
            case AKMidiStatusProgramChange:
                _length = 2;
                break;
            default:
                _length = 3;
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
                _length = 3;
                break;
            case AKMidiCommandSongSelect:
                _data[1] = d1 & 0x7F;
                _length = 2;
                break;
            default: // All other commands don't require a parameter or are undefined
                _length = 1;
                break;
        }
    }
    return self;
}

- (instancetype)initWithMIDIPacket:(const UInt8 [3])packet
{
    if (packet[0] < 0xF0) {
        return [self initWithStatus:(packet[0] >> 4) channel:(packet[0] & 0xF)+1 data1:packet[1] data2:packet[2]];
    } else {
        return [self initWithSystemCommand:packet[0] data1:packet[1] data2:packet[2]];
    }
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        [data getBytes:_data length:sizeof(_data)];
        _length = (data.length > sizeof(_data)) ? sizeof(_data) : data.length;
    }
    return self;
}

+ (NSArray<AKMidiEvent *> *)midiEventsFromPacket:(const MIDIPacket *)packet
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:packet->length/3];
    for(NSUInteger i = 0; i < packet->length; i += 3) {
        AKMidiEvent *event = [[AKMidiEvent alloc] initWithMIDIPacket:&packet->data[i]];
        [ret addObject:event];
    }
    return ret;
}


- (AKMidiStatus)status
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
        return (_data[0] & 0xF) + 1;
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
    return [NSData dataWithBytes:_data length:self.length];
}

- (void)copyBytes:(void *)ptr
{
    memcpy(ptr, _data, self.length);
}

- (BOOL)postNotification
{
    NSDictionary *ret = nil;
    NSString *name = nil;
    
    switch (self.status) {
        case AKMidiStatusNoteOn: {
            ret = @{@"note":@(self.data1),
                    @"velocity":@(self.data2),
                    @"channel":@(self.channel)};
            name = AKMidiNoteOnNotification;
            break;
        }
        case AKMidiStatusNoteOff: {
            ret = @{@"note":@(self.data1),
                    @"velocity":@(self.data2),
                    @"channel":@(self.channel)};
            name = AKMidiNoteOffNotification;
            break;
        }
        case AKMidiStatusPolyphonicAftertouch: {
            ret = @{@"note":@(self.data1),
                    @"pressure":@(self.data2),
                    @"channel":@(self.channel)};
            name = AKMidiPolyphonicAftertouchNotification;
            break;
        }
        case AKMidiStatusChannelAftertouch: {
            ret = @{@"pressure":@(self.data1),
                    @"channel":@(self.channel)};
            name = AKMidiAftertouchNotification;
            break;
        }
        case AKMidiStatusPitchWheel: {
            ret = @{@"pitchWheel":@(self.data),
                    @"channel":@(self.channel)};
            name = AKMidiPitchWheelNotification;
            break;
        }
        case AKMidiStatusProgramChange: {
            ret = @{@"program":@(self.data1),
                    @"channel":@(self.channel)};
            name = AKMidiProgramChangeNotification;
            break;
        }
        case AKMidiStatusControllerChange: {
            switch(self.data1) {
                case AKMidiControlModulationWheel:
                    name = AKMidiModulationNotification;
                    break;
                case AKMidiControlPortamento:
                    name = AKMidiPortamentoNotification;
                    break;
                case AKMidiControlMainVolume:
                    name = AKMidiVolumeNotification;
                    break;
                case AKMidiControlBalance:
                    name = AKMidiBalanceNotification;
                    break;
                case AKMidiControlPan:
                    name = AKMidiPanNotification;
                    break;
                case AKMidiControlExpression:
                    name = AKMidiExpressionNotification;
                    break;
                default: // Catch-all
                    name = AKMidiControlNotification;
                    break;
            }
            ret = @{@"controller":@(self.data1),
                    @"value":@(self.data2),
                    @"channel":@(self.channel)};
            break;
        }
        case AKMidiStatusSystemCommand: {
            switch (self.command) {
                case AKMidiCommandClock:
                    //NSLog(@"MIDI Clock");
                    break;
                case AKMidiCommandSysex:
                    break;
                case AKMidiCommandSysexEnd:
                    NSLog(@"SysEx EOX");
                    break;
                case AKMidiCommandSysReset:
                    NSLog(@"MIDI System Reset");
                    break;
                default:
                    break;
            }
            break;
        }
    }
    if (ret) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:self
                                                          userInfo:ret];
        return YES;
    }
    return NO;
}

- (NSString *)description {
    NSMutableString *ret = [NSMutableString stringWithString:@"<MIDI:"];
    for (int i = 0; i < self.length; i++) {
        [ret appendFormat:@" %02X",_data[i]];
    }
    [ret appendString:@">"];
    return ret;
}

#pragma mark - Utility constructors for common MIDI events

+ (instancetype)eventWithNoteOn:(UInt8)note channel:(UInt8)channel velocity:(UInt8)velocity
{
    return [[AKMidiEvent alloc] initWithStatus:AKMidiStatusNoteOn channel:channel data1:note data2:velocity];
}

+ (instancetype)eventWithNoteOff:(UInt8)note channel:(UInt8)channel velocity:(UInt8)velocity
{
    return [[AKMidiEvent alloc] initWithStatus:AKMidiStatusNoteOff channel:channel data1:note data2:velocity];
}

+ (instancetype)eventWithProgramChange:(UInt8)program channel:(UInt8)channel
{
    return [[AKMidiEvent alloc] initWithStatus:AKMidiStatusProgramChange channel:channel data1:program data2:0];
}


@end

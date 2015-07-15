//
//  AKMidi.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKMidi.h"
#import <CoreMIDI/CoreMIDI.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CoreMIDI/MIDINetworkSession.h>
#endif

NSString * const AKMidiNoteOn               = @"AKMidiNoteOn";
NSString * const AKMidiNoteOff              = @"AKMidiNoteOff";
NSString * const AKMidiPolyphonicAftertouch = @"AKMidiPolyphonicAftertouch";
NSString * const AKMidiProgramChange        = @"AKMidiProgramChange";
NSString * const AKMidiAftertouch           = @"AKMidiAftertouch";
NSString * const AKMidiPitchWheel           = @"AKMidiPitchWheel";
NSString * const AKMidiController           = @"AKMidiController";
NSString * const AKMidiModulation           = @"AKMidiModulation";
NSString * const AKMidiPortamento           = @"AKMidiPortamento";
NSString * const AKMidiVolume               = @"AKMidiVolume";
NSString * const AKMidiBalance              = @"AKMidiBalance";
NSString * const AKMidiPan                  = @"AKMidiPan";
NSString * const AKMidiExpression           = @"AKMidiExpression";


@implementation AKMidi
{
    MIDIClientRef _client;
    MIDIPortRef _inPort;
}

/// MIDI note on/off, control and system exclusive constants

// These are the top 4 bits of the MIDI command, for commands that take a channel number in the low 4 bits
typedef NS_ENUM(UInt8, AKMidiConstant)
{
    AKMidiConstantNoteOff = 8,
    AKMidiConstantNoteOn = 9,
    AKMidiConstantPolyphonicAftertouch = 10,
    AKMidiConstantControllerChange = 11,
    AKMidiConstantProgramChange = 12,
    AKMidiConstantAftertouch = 13,
    AKMidiConstantPitchWheel = 14,
    AKMidiConstantSystemCommand = 15
};

// System commands (8 bits - 0xFx) that do not require a channel number
typedef NS_ENUM(UInt8, AKMidiSystemCommand)
{
    AKMidiCommandSysex = 240,
    AKMidiCommandSysexEnd = 247,
    AKMidiCommandClock = 248,
    AKMidiCommandStart = 250,
    AKMidiCommandContinue = 251,
    AKMidiCommandStop = 252,
    AKMidiCommandActiveSensing = 254,
    AKMidiCommandSysReset = 255
};


#pragma mark - Initialization

- (instancetype)init
{
    if(self = [super init]) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        MIDINetworkSession *session = [MIDINetworkSession defaultSession];
        session.enabled = YES;
        session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
#endif
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - Broadcast MIDI Events
// -----------------------------------------------------------------------------

static void dumpPacket(MIDIPacket *packet, NSString *info)
{
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < packet->length; i++) {
        [str appendFormat:@"%i ", packet->data[i]];
    }
    NSLog(@"%@: %@", info, str);
}

static void AKMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    AKMidi *m = (__bridge AKMidi *)refCon;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (uint i=0; i < pktlist->numPackets; i++) {
		UInt8 midiStatus = packet->data[0];
		UInt8 midiCommand = midiStatus >> 4;
        UInt8 midiChannel = (midiStatus & 0x0F) + 1;
		
		switch (midiCommand) {
            case AKMidiConstantNoteOff: {
                UInt8 note     = packet->data[1] & 0x7F;
                UInt8 velocity = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"note":@(note),
                                       @"velocity":@(velocity),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiNoteOff object:m userInfo:dict];
                break;
            }
            case AKMidiConstantNoteOn: {
                UInt8 note     = packet->data[1] & 0x7F;
                UInt8 velocity = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"note":@(note),
                                       @"velocity":@(velocity),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiNoteOn object:m userInfo:dict];
                break;
            }
            case AKMidiConstantPolyphonicAftertouch: {
                UInt8 note     = packet->data[1] & 0x7F;
                UInt8 pressure = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"note":@(note),
                                       @"pressure":@(pressure),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiPolyphonicAftertouch object:m userInfo:dict];
                break;
            }
            case AKMidiConstantAftertouch: {
                UInt8 pressure = packet->data[1] & 0x7F;
                NSDictionary *dict = @{@"pressure":@(pressure),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiAftertouch object:m userInfo:dict];
                break;
            }
            case AKMidiConstantPitchWheel: {
                UInt8 value1 = packet->data[1] & 0x7F;
                UInt8 value2 = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"pitchWheel":@(128*value2+value1),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiPitchWheel object:m userInfo:dict];
                break;
            }
            case AKMidiConstantProgramChange: {
                UInt8 program = packet->data[1] & 0x7F;
                NSDictionary *dict = @{@"program":@(program),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiProgramChange object:m userInfo:dict];
                break;
            }
            case AKMidiConstantControllerChange: {
                UInt8 controller = packet->data[1] & 0x7F;
                UInt8 value      = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"controller":@(controller),
                                       @"value":@(value),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiController object:m userInfo:dict];
                
                NSDictionary *smallDict = @{@"value":@(value),
                                            @"channel":@(midiChannel)};
                switch (controller) {
                    case 1:
                        [nc postNotificationName:AKMidiModulation object:m userInfo:smallDict];
                        break;
                    case 5:
                        [nc postNotificationName:AKMidiPortamento object:m userInfo:smallDict];
                        break;
                    case 7:
                        [nc postNotificationName:AKMidiVolume object:m userInfo:smallDict];
                        break;
                    case 8:
                        [nc postNotificationName:AKMidiBalance object:m userInfo:smallDict];
                        break;
                    case 10:
                        [nc postNotificationName:AKMidiPan object:m userInfo:smallDict];
                        break;
                    case 11:
                        [nc postNotificationName:AKMidiExpression object:m userInfo:smallDict];
                        break;
                    default:
                        break;
                }
                break;
            }
            case AKMidiConstantSystemCommand: {
                switch (midiStatus) {
                    case AKMidiCommandClock:
                        NSLog(@"MIDI Clock");
                        break;
                    case AKMidiCommandSysex:
                        dumpPacket(packet, @"SysEx");
                        break;
                    case AKMidiCommandSysexEnd:
                        NSLog(@"SysEx EOX");
                        break;
                    case AKMidiCommandSysReset:
                        NSLog(@"MIDI System Reset");
                        break;
                }
                break;
            }
            default: { // Other
                dumpPacket(packet, @"Unparsed MIDI");
                break;
            }
        }
        packet = MIDIPacketNext(packet);
    }
}

static void AKMIDINotifyProc(const MIDINotification *message, void *refCon)
{
    NSLog(@"MIDI Notify, messageId=%@, size=%@", @(message->messageID), @(message->messageSize));
}

- (void)openMidiIn
{
    _inputs = MIDIGetNumberOfSources();
    NSLog(@"%@ MIDI sources\n", @(_inputs));
    
    if (_inputs == 0)
        return;
    
    MIDIClientCreate(CFSTR("CoreMIDI AudioKit"), AKMIDINotifyProc, (__bridge void *)self, &_client);
	MIDIInputPortCreate(_client, CFSTR("AK Input port"), AKMIDIReadProc, (__bridge void *)self, &_inPort);
	
	for (NSUInteger i = 0; i < _inputs; ++i) {
		MIDIEndpointRef src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName);
		NSLog(@"MIDI source %@: %@", @(i), endpointName);
		MIDIPortConnectSource(_inPort, src, NULL);
	}
    
}

-(void)closeMidiIn
{
    MIDIClientDispose(_client);
}

- (void)dealloc
{
    MIDIClientDispose(_client);
    MIDIPortDispose(_inPort);
}

@end

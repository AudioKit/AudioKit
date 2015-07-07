//
//  AKMidi.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKMidi.h"
#import "AKSettings.h"
#import <CoreMIDI/CoreMIDI.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CoreMIDI/MIDINetworkSession.h>
#endif

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
                [nc postNotificationName:AKMidiNoteOffNotification object:m userInfo:dict];
                break;
            }
            case AKMidiConstantNoteOn: {
                UInt8 note     = packet->data[1] & 0x7F;
                UInt8 velocity = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"note":@(note),
                                       @"velocity":@(velocity),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiNoteOnNotification object:m userInfo:dict];
                break;
            }
            case AKMidiConstantPolyphonicAftertouch: {
                UInt8 note     = packet->data[1] & 0x7F;
                UInt8 pressure = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"note":@(note),
                                       @"pressure":@(pressure),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiPolyphonicAftertouchNotification object:m userInfo:dict];
                break;
            }
            case AKMidiConstantAftertouch: {
                UInt8 pressure = packet->data[1] & 0x7F;
                NSDictionary *dict = @{@"pressure":@(pressure),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiAftertouchNotification object:m userInfo:dict];
                break;
            }
            case AKMidiConstantPitchWheel: {
                UInt8 value1 = packet->data[1] & 0x7F;
                UInt8 value2 = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"pitchWheel":@(128*value2+value1),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiPitchWheelNotification object:m userInfo:dict];
                break;
            }
            case AKMidiConstantProgramChange: {
                UInt8 program = packet->data[1] & 0x7F;
                NSDictionary *dict = @{@"program":@(program),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiProgramChangeNotification object:m userInfo:dict];
                break;
            }
            case AKMidiConstantControllerChange: {
                UInt8 controller = packet->data[1] & 0x7F;
                UInt8 value      = packet->data[2] & 0x7F;
                NSDictionary *dict = @{@"controller":@(controller),
                                       @"value":@(value),
                                       @"channel":@(midiChannel)};
                [nc postNotificationName:AKMidiControllerNotification object:m userInfo:dict];
                
                NSDictionary *smallDict = @{@"value":@(value),
                                            @"channel":@(midiChannel)};
                switch (controller) {
                    case 1:
                        [nc postNotificationName:AKMidiModulationNotification object:m userInfo:smallDict];
                        break;
                    case 5:
                        [nc postNotificationName:AKMidiPortamentoNotification object:m userInfo:smallDict];
                        break;
                    case 7:
                        [nc postNotificationName:AKMidiVolumeNotification object:m userInfo:smallDict];
                        break;
                    case 8:
                        [nc postNotificationName:AKMidiBalanceNotification object:m userInfo:smallDict];
                        break;
                    case 10:
                        [nc postNotificationName:AKMidiPanNotification object:m userInfo:smallDict];
                        break;
                    case 11:
                        [nc postNotificationName:AKMidiExpressionNotification object:m userInfo:smallDict];
                        break;
                    default:
                        break;
                }
                break;
            }
            case AKMidiConstantSystemCommand: {
                switch (midiStatus) {
                    case AKMidiCommandClock:
                        //NSLog(@"MIDI Clock");
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
    AKMidi *m = (__bridge AKMidi *)refCon;

    // Detect when new audio inputs have become available, and reinit
    switch (message->messageID) {
        case kMIDIMsgSetupChanged:
            if (AKSettings.shared.loggingEnabled)
                NSLog(@"MIDI Setup changed");
            [m openMidiIn];
            break;
        case kMIDIMsgPropertyChanged: {
            const MIDIObjectPropertyChangeNotification *msg = (const MIDIObjectPropertyChangeNotification*)message;
            if (AKSettings.shared.loggingEnabled)
                NSLog(@"MIDI Property changed: %@", msg->propertyName);
            break;
        }
        case kMIDIMsgObjectAdded:
            if (AKSettings.shared.loggingEnabled)
                NSLog(@"MIDI Object Added");
            break;
        case kMIDIMsgObjectRemoved:
            if (AKSettings.shared.loggingEnabled)
                NSLog(@"MIDI Object removed");
            break;
        default:
            if (AKSettings.shared.loggingEnabled)
                NSLog(@"MIDI Notify, messageId=%d, size=%d", message->messageID, message->messageSize);
            break;
    }
}

- (void)openMidiIn
{
    _inputs = MIDIGetNumberOfSources();
    NSLog(@"%@ MIDI sources\n", @(_inputs));
    
    if (_inputs == 0)
        return;
    
    if (!_client)
        MIDIClientCreate(CFSTR("CoreMIDI AudioKit"), AKMIDINotifyProc, (__bridge void *)self, &_client);
    if (!_inPort)
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
    _client = 0;
}

- (void)dealloc
{
    MIDIClientDispose(_client);
    MIDIPortDispose(_inPort);
}

@end

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
    MIDIClientRef client;
}

/// MIDI note on/off, control and system exclusive constants
typedef NS_OPTIONS(NSUInteger, AKMidiConstant)
{
    AKMidiConstantNoteOff = 8,
    AKMidiConstantNoteOn = 9,
    AKMidiConstantPolyphonicAftertouch = 10,
    AKMidiConstantControllerChange = 11,
    AKMidiConstantProgramChange = 12,
    AKMidiConstantAftertouch = 13,
    AKMidiConstantPitchWheel = 14,
    AKMidiConstantSysex = 240
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

void MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    //AKMidi *m = (__bridge AKMidi *)refCon;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (uint i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        Byte midiChannel = (midiStatus - (midiCommand*16)) + 1;
		
		if (midiCommand == AKMidiConstantNoteOff) {
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            NSDictionary *dict = @{@"note":@(note),
                                   @"velocity":@(velocity),
                                   @"channel":@(midiChannel)};
            [nc postNotificationName:AKMidiNoteOff object:dict];
            
		} else if (midiCommand == AKMidiConstantNoteOn) {
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            NSDictionary *dict = @{@"note":@(note),
                                   @"velocity":@(velocity),
                                   @"channel":@(midiChannel)};
            [nc postNotificationName:AKMidiNoteOn object:dict];
            
		} else if (midiCommand == AKMidiConstantPolyphonicAftertouch) {
			Byte note     = packet->data[1] & 0x7F;
			Byte pressure = packet->data[2] & 0x7F;
            NSDictionary *dict = @{@"note":@(note),
                                   @"pressure":@(pressure),
                                   @"channel":@(midiChannel)};
            [nc postNotificationName:AKMidiPolyphonicAftertouch object:dict];
            
        } else if (midiCommand == AKMidiConstantAftertouch) {
			Byte pressure = packet->data[2] & 0x7F;
            NSDictionary *dict = @{@"pressure":@(pressure),
                                   @"channel":@(midiChannel)};
            [nc postNotificationName:AKMidiAftertouch object:dict];
            
		} else if (midiCommand == AKMidiConstantPitchWheel) {
            Byte value1 = packet->data[1] & 0x7F;
			Byte value2 = packet->data[2] & 0x7F;
            NSDictionary *dict = @{@"pitchWheel":@(128*value2+value1),
                                   @"channel":@(midiChannel)};
            [nc postNotificationName:AKMidiPitchWheel object:dict];
            
		} else if (midiCommand == AKMidiConstantControllerChange) {
			Byte controller = packet->data[1] & 0x7F;
			Byte value      = packet->data[2] & 0x7F;
            NSDictionary *dict = @{@"controller":@(controller),
                                   @"value":@(value),
                                   @"channel":@(midiChannel)};
            [nc postNotificationName:AKMidiController object:dict];
            
            NSDictionary *smallDict = @{@"value":@(value),
                                        @"channel":@(midiChannel)};
            switch (controller) {
                case 1:
                    [nc postNotificationName:AKMidiModulation object:smallDict];
                    break;
                case 5:
                    [nc postNotificationName:AKMidiPortamento object:smallDict];
                    break;
                case 7:
                    [nc postNotificationName:AKMidiVolume object:smallDict];
                    break;
                case 8:
                    [nc postNotificationName:AKMidiBalance object:smallDict];
                    break;
                case 10:
                    [nc postNotificationName:AKMidiPan object:smallDict];
                    break;
                case 11:
                    [nc postNotificationName:AKMidiExpression object:smallDict];
                    break;
                default:
                    break;
            }
            
        } else if (midiCommand == AKMidiConstantProgramChange) {
            
        } else { // Other
            
            
            int b[10];
            for (int i=0; i<=9; i++) {
                b[i] = (packet->length > i) ? packet->data[i] : 0;
            }
            
            if (midiStatus == AKMidiConstantSysex) {
                NSLog(@"Unparsed Sysex: %i %i %i %i %i %i %i %i %i", b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);
            } else {
                NSLog(@"Unparsed MIDI: %i %i %i %i %i %i %i %i %i %i", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);
                
            }
            
        }
		packet = MIDIPacketNext(packet);
	}
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon)
{
//	printf("MIDI Notify, messageId=%d,", message->messageID);
}

- (void)openMidiIn
{
    NSLog(@"Opening Midi In");
    MIDIClientCreate(CFSTR("Core MIDI to System Sounds Demo"), MyMIDINotifyProc, (__bridge void *)(self), &client);
	MIDIPortRef inPort;
	MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, (__bridge void *)(self), &inPort);
	
	unsigned long sourceCount = MIDIGetNumberOfSources();
    NSLog(@"%ld sources\n", sourceCount);
	for (uint i = 0; i < sourceCount; ++i) {
		MIDIEndpointRef src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName);
		char endpointNameC[255];
		CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
		NSLog(@"source %d: %s\n", i, endpointNameC);
		MIDIPortConnectSource(inPort, src, NULL);
	}
    
}

-(void)closeMidiIn
{
    NSLog(@"Closing Midi In");
    MIDIClientDispose(client);
}

@end

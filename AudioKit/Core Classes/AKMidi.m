//
//  AKMidi.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKMidi.h"
#import <CoreMIDI/CoreMIDI.h>

#pragma mark  Utility Function

@implementation AKMidi
{
    MIDIClientRef client;
}

#pragma mark - Initialization

- (instancetype)init
{
    if(self = [super init]) {
        _listeners = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)addListener:(id<AKMidiListener>)listener
{
    NSLog(@"Adding listener");
    [_listeners addObject:listener];
}


// -----------------------------------------------------------------------------
#  pragma mark - Broadcast MIDI Events
// -----------------------------------------------------------------------------

- (void)broadcastNoteOn:(int)note velocity:(int)velocity channel:(int)channel
{
    for (id<AKMidiListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(midiNoteOn:velocity:channel:)]) {
            [listener midiNoteOn:note velocity:velocity channel:channel];
        }
    }
}

- (void)broadcastNoteOff:(int)note velocity:(int)velocity channel:(int)channel
{
    for (id<AKMidiListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(midiNoteOff:velocity:channel:)]) {
            [listener midiNoteOff:note velocity:velocity channel:channel];
        }
    }
}

- (void)broadcastAftertouchOnNote:(int)note pressure:(int)pressure channel:(int)channel
{
    for (id<AKMidiListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(midiAftertouchOnNote:pressure:channel:)]) {
            [listener midiAftertouchOnNote:note pressure:pressure channel:channel];
        }
    }
}

- (void)broadcastAftertouch:(int)pressure channel:(int)channel
{
    for (id<AKMidiListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(midiAftertouch:channel:)]) {
            [listener midiAftertouch:pressure channel:channel];
        }
    }
}

- (void)broadcastPitchWheel:(int)pitchWheelValue channel:(int)channel
{
    for (id<AKMidiListener> listener in _listeners) {
        if ([listener respondsToSelector:@selector(midiPitchWheel:channel:)]) {
            [listener midiPitchWheel:pitchWheelValue  channel:channel];
        }
    }
}


- (void)broadcastChangeController:(int)controller toValue:(int)value channel:(int)channel
{
    for (id<AKMidiListener> listener in _listeners) {
        [listener midiController:controller changedToValue:value channel:channel];
        switch (controller) {
            case 1:
                if ([listener respondsToSelector:@selector(midiModulation:channel:)]) {
                    [listener midiModulation:value channel:channel];
                }
                break;
            case 5:
                if ([listener respondsToSelector:@selector(midiPortamento:channel:)]) {
                    [listener midiPortamento:value channel:channel];
                }
                break;
            case 7:
                if ([listener respondsToSelector:@selector(midiVolume:channel:)]) {
                    [listener midiVolume:value channel:channel];
                }
                break;
            case 8:
                if ([listener respondsToSelector:@selector(midiBalance:channel:)]) {
                    [listener midiBalance:value channel:channel];
                }
                break;
            case 10:
                if ([listener respondsToSelector:@selector(midiPan:channel:)]) {
                    [listener midiPan:value channel:channel];
                }
                break;
            case 11:
                if ([listener respondsToSelector:@selector(midiExpression:channel:)]) {
                    [listener midiExpression:value channel:channel];
                }
                break;
            default:
                break;
        }
    }
}


// -----------------------------------------------------------------------------
#  pragma mark - Low Level MIDI Handlining
// -----------------------------------------------------------------------------


void MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    AKMidi *m = (__bridge AKMidi *)refCon;
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (uint i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        Byte midiChannel = (midiStatus - (midiCommand*16)) + 1;
		
		if (midiCommand == AKMidiConstantNoteOff) {
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            [m broadcastNoteOff:(int)note velocity:(int)velocity channel:(int)midiChannel];
            
		} else if (midiCommand == AKMidiConstantNoteOn) {
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            [m broadcastNoteOn:(int)note velocity:(int)velocity channel:(int)midiChannel];
            
		} else if (midiCommand == AKMidiConstantPolyphonicAftertouch) {
			Byte note     = packet->data[1] & 0x7F;
			Byte pressure = packet->data[2] & 0x7F;
            [m broadcastAftertouchOnNote:(int)note pressure:(int)pressure channel:(int)midiChannel];
            
        } else if (midiCommand == AKMidiConstantAftertouch) {
			Byte pressure = packet->data[2] & 0x7F;
            [m broadcastAftertouch:(int)pressure channel:(int)midiChannel];
            
		} else if (midiCommand == AKMidiConstantPitchWheel) {
            Byte value1 = packet->data[1] & 0x7F;
			Byte value2 = packet->data[2] & 0x7F;
            [m broadcastPitchWheel:128*value2+value1 channel:(int)midiChannel];
            
            
		} else if (midiCommand == AKMidiConstantControllerChange) {
			Byte controller = packet->data[1] & 0x7F;
			Byte value      = packet->data[2] & 0x7F;
            [m broadcastChangeController:(int)controller toValue:(int)value channel:(int)midiChannel];
            
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
	//printf("MIDI Notify, messageId=%d,", message->messageID);
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

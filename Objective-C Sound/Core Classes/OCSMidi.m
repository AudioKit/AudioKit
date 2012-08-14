//
//  OCSMidi.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMidi.h"
#import <CoreMIDI/CoreMIDI.h>

#pragma mark  Utility Function

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char errorString[20];
    // See if it appears to be a 4-char code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error %s (%s)\n", operation, errorString);
    exit(1);
}

@interface OCSMidi() {
    MIDIClientRef client;
}
@end

@implementation OCSMidi

@synthesize listeners;

#pragma mark - Initialization

-(id)init
{
    NSLog(@"Initializing Midi");
    if(self = [super init]) {
        listeners = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)addListener:(id<OCSMidiListener>)listener {
    NSLog(@"Adding listener");
    [listeners addObject:listener];
}



#pragma mark - Broadcast MIDI Events

- (void)broadcastNoteOn:(int)note velocity:(int)velocity channel:(int)channel {
    for (id<OCSMidiListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(midiNoteOn:velocity:channel:)]) {
            [listener midiNoteOn:note velocity:velocity channel:channel];
        }
    }
}

- (void)broadcastNoteOff:(int)note velocity:(int)velocity channel:(int)channel {
    for (id<OCSMidiListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(midiNoteOff:velocity:channel:)]) {
            [listener midiNoteOff:note velocity:velocity channel:channel];
        }
    }
}

- (void)broadcastAftertouchOnNote:(int)note pressure:(int)pressure channel:(int)channel {
    for (id<OCSMidiListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(midiAftertouchOnNote:pressure:channel:)]) {
            [listener midiAftertouchOnNote:note pressure:pressure channel:channel];
        }
    }
}

- (void)broadcastAftertouch:(int)pressure channel:(int)channel {
    for (id<OCSMidiListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(midiAftertouch:channel:)]) {
            [listener midiAftertouch:pressure channel:channel];
        }
    }
}

- (void)broadcastPitchWheel:(int)pitchWheelValue channel:(int)channel {
    for (id<OCSMidiListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(midiPitchWheel:channel:)]) {
            [listener midiPitchWheel:pitchWheelValue  channel:channel];
        }
    }
}


- (void)broadcastChangeController:(int)controller toValue:(int)value channel:(int)channel {
    for (id<OCSMidiListener> listener in listeners) {
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


#pragma mark - Low Level MIDI Handlining

typedef enum MIDIConstants {
    kMidiNoteOff = 8,
    kMidiNoteOn = 9,
    kMidiPolyphonicAftertouch = 10,
    kMidiControllerChange = 11,
    kMidiProgramChange = 12,
    kMidiAftertouch = 13,
    kMidiPitchWheel = 14,
    kMidiSysex = 240
} MIDIConstants;


void MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
    OCSMidi *m = (__bridge OCSMidi *)refCon;
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (int i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        Byte midiChannel = 1 + (midiStatus - (midiCommand*16));
		
		if (midiCommand == kMidiNoteOff) {
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            [m broadcastNoteOff:(int)note velocity:(int)velocity channel:(int)midiChannel];
            
		} else if (midiCommand == kMidiNoteOn) { 
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            [m broadcastNoteOn:(int)note velocity:(int)velocity channel:(int)midiChannel];
            
		} else if (midiCommand == kMidiPolyphonicAftertouch) {
			Byte note     = packet->data[1] & 0x7F;
			Byte pressure = packet->data[2] & 0x7F;
            [m broadcastAftertouchOnNote:(int)note pressure:(int)pressure channel:(int)midiChannel];
            
        } else if (midiCommand == kMidiAftertouch) {
			Byte pressure = packet->data[2] & 0x7F;
            [m broadcastAftertouch:(int)pressure channel:(int)midiChannel];
            
		} else if (midiCommand == kMidiPitchWheel) {
            Byte value1 = packet->data[1] & 0x7F;
			Byte value2 = packet->data[2] & 0x7F;
            [m broadcastPitchWheel:128*value2+value1 channel:(int)midiChannel];
            
            
		} else if (midiCommand == kMidiControllerChange) {
			Byte controller = packet->data[1] & 0x7F;
			Byte value      = packet->data[2] & 0x7F;
            [m broadcastChangeController:(int)controller toValue:(int)value channel:(int)midiChannel];
            
        } else if (midiCommand == kMidiProgramChange) {
            
        } else { // Other

                            
            int b[10];
            for (int i=0; i<=9; i++) {
                b[i] = (packet->length > i) ? packet->data[i] : 0;
            }
                
            if (midiStatus == kMidiSysex) {
                NSLog(@"Unparsed Sysex: %i %i %i %i %i %i %i %i %i", b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);
            } else {
                NSLog(@"Unparsed MIDI: %i %i %i %i %i %i %i %i %i %i", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);

            }
            
        }
		packet = MIDIPacketNext(packet);
	}
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
	//printf("MIDI Notify, messageId=%d,", message->messageID);
}

- (void)openMidiIn
{
    NSLog(@"Opening Midi In");
    CheckError (MIDIClientCreate(CFSTR("Core MIDI to System Sounds Demo"), MyMIDINotifyProc, (__bridge void *)(self), &client),
				"Couldn't create MIDI client");
	
	MIDIPortRef inPort;
	CheckError (MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, (__bridge void *)(self), &inPort),
				"Couldn't create MIDI input port");
	
	unsigned long sourceCount = MIDIGetNumberOfSources();
    NSLog(@"%ld sources\n", sourceCount);
	for (int i = 0; i < sourceCount; ++i) {
		MIDIEndpointRef src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		CheckError(MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName),
				   "Couldn't get endpoint name");
		char endpointNameC[255];
		CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
		NSLog(@"source %d: %s\n", i, endpointNameC);
		CheckError (MIDIPortConnectSource(inPort, src, NULL),
					"Couldn't connect MIDI port");
	}

}

-(void)closeMidiIn
{
    NSLog(@"Closing Midi In");
    MIDIClientDispose(client);
}

@end

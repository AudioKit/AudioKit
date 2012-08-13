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

- (void)broadcastNoteOn:(int)note velocity:(int)velocity {
    for (id<OCSMidiListener> listener in listeners) {
        [listener midiNoteOn:note velocity:velocity];
    }
}

- (void)broadcastNoteOff:(int)note velocity:(int)velocity {
    for (id<OCSMidiListener> listener in listeners) {
        [listener midiNoteOff:note velocity:velocity];
    }
}

- (void)broadcastAftertouchOnNote:(int)note pressure:(int)pressure {
    for (id<OCSMidiListener> listener in listeners) {
        [listener midiAftertouchOnNote:note pressure:pressure];
    }
}

- (void)broadcastChangeController:(int)controller toValue:(int)value {
    for (id<OCSMidiListener> listener in listeners) {
        [listener midiController:controller changedToValue:value];
        switch (controller) {
            case 1:
                [listener midiModulation:value];
                break;
            case 5:
                [listener midiPortamento:value];
                break;
            case 7:
                [listener midiVolume:value];
                break;
            case 8:
                [listener midiBalance:value];
                break;
            case 10:
                [listener midiPan:value];
                break;
            case 11:
                [listener midiExpression:value];
                break;
            default:
                break;
        }
    }
}

- (void)broadcastAftertouch:(int)pressure {
    for (id<OCSMidiListener> listener in listeners) {
        [listener midiAftertouch:pressure];
    }
}

- (void)broadcastPitchWheel:(int)pitchWheelValue {
    for (id<OCSMidiListener> listener in listeners) {
        [listener midiPitchWheel:pitchWheelValue];
    }
}

#pragma mark - Low Level MIDI Handlining

void MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
    OCSMidi *m = (__bridge OCSMidi *)refCon;
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (int i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
		
		if (midiCommand == 8) { // Note Off
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            [m broadcastNoteOff:(int)note velocity:(int)velocity];
            
		} else if (midiCommand == 9) { // Note On
			Byte note     = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
            [m broadcastNoteOn:(int)note velocity:(int)velocity];
            
		} else if (midiCommand == 10) { // Polyphonic After-touch
			Byte note     = packet->data[1] & 0x7F;
			Byte pressure = packet->data[2] & 0x7F;
            [m broadcastAftertouchOnNote:(int)note pressure:(int)pressure];
            
		} else if (midiCommand == 11) { // Controller Change
			Byte controller = packet->data[1] & 0x7F;
			Byte value      = packet->data[2] & 0x7F;
            [m broadcastChangeController:(int)controller toValue:(int)value];
            
        } else if (midiCommand == 13) { // Global After-touch
			Byte pressure = packet->data[2] & 0x7F;
            [m broadcastAftertouch:(int)pressure];
            
		} else if (midiCommand == 14) { // Pitch Wheel
            Byte value1 = packet->data[1] & 0x7F;
			Byte value2 = packet->data[2] & 0x7F;
            [m broadcastPitchWheel:128*value2+value1];
            
        } else { // Other            
            int b[10];
            for (int i=0; i<=9; i++) {
                b[i] = (packet->length > i) ? packet->data[i] : 0;
            }
            NSLog(@"Unparsed MIDI: %i %i %i %i %i %i %i %i %i %i", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);

        }
		packet = MIDIPacketNext(packet);
	}
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
	printf("MIDI Notify, messageId=%ld,", message->messageID);
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

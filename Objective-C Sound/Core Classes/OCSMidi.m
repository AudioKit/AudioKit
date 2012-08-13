//
//  OCSMidi.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMidi.h"
#import <CoreMIDI/CoreMIDI.h>

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
    NSLog(@"listeners %i", [listeners count]);
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
	printf("MIDI Notify, messageId=%ld,", message->messageID);
}

- (void)broadcastNoteOn:(int)note velocity:(int)velocity {
    for (id<OCSMidiListener> listener in listeners) {
        [listener noteOn:note velocity:velocity];
    }
}

- (void)broadcastNoteOff:(int)note velocity:(int)velocity {
    for (id<OCSMidiListener> listener in listeners) {
        [listener noteOff:note velocity:velocity];
    }
}

- (void)broadcastChangeController:(int)controller toValue:(int)value {
    for (id<OCSMidiListener> listener in listeners) {
        [listener controller:controller changedToValue:value];
    }
}

void MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
    OCSMidi *m = (__bridge OCSMidi *)refCon;
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (int i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        
        
        //Control Change
        if (midiCommand == 0x11) {
			Byte controller = packet->data[1] & 0x7F;
			Byte value = packet->data[2] & 0x7F;
			printf("midiCommand=%d. Controller=%d, Value=%d\n", midiCommand, controller, value);
            [m broadcastChangeController:(int)controller toValue:(int)value];
            
		}
        
		// Note On
		if (midiCommand == 0x09) {
			Byte note = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
			printf("midiCommand=%d. Note=%d, Velocity=%d\n", midiCommand, note, velocity);
            [m broadcastNoteOn:(int)note velocity:(int)velocity];

		}
        
        // Note Off
        if (midiCommand == 0x08) {
			Byte note = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
			printf("midiCommand=%d. Note=%d, Velocity=%d\n", midiCommand, note, velocity);
            [m broadcastNoteOff:(int)note velocity:(int)velocity];
            
		}
		packet = MIDIPacketNext(packet);
	}
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

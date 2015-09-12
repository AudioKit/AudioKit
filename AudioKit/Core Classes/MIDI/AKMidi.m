//
//  AKMidi.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKMidi.h"
#import "AKSettings.h"
#import "AKManager.h"

#import <CoreMIDI/CoreMIDI.h>
#import "csound.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CoreMIDI/MIDINetworkSession.h>
#endif

@implementation AKMidi
{
    MIDIClientRef _client;
    MIDIPortRef _inPort;
    NSMutableArray *_events; // Buffer of pending events to send to Csound
}


#pragma mark - Initialization

- (instancetype)init
{
    if(self = [super init]) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        MIDINetworkSession *session = [MIDINetworkSession defaultSession];
        session.enabled = YES;
        session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
#endif
        _events = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)connectToCsound:(CsoundObj *)csound
{
    NSAssert(csound.csound, @"Csound object is not yet ready to use!");
    csoundSetExternalMidiInOpenCallback(csound.csound, AKMidiInDeviceOpen);
    csoundSetExternalMidiReadCallback(csound.csound, AKMidiDataRead);
    csoundSetExternalMidiInCloseCallback(csound.csound, AKMidiInDeviceClose);
    csoundSetHostImplementedMIDIIO(csound.csound, 1);
    _forwardEvents = YES;
}

// -----------------------------------------------------------------------------
#  pragma mark - Broadcast CoreMIDI Events
// -----------------------------------------------------------------------------

static void AKMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    AKMidi *m = (__bridge AKMidi *)refCon;
    
    @autoreleasepool {
        MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
        for (uint i = 0; i < pktlist->numPackets; i++) {
            NSArray<AKMidiEvent *> *events = [AKMidiEvent midiEventsFromPacket:packet];
            
            for (AKMidiEvent *event in events) {
                if (event.command == AKMidiCommandClock)
                    continue;
                if (m.forwardEvents) {
                    [m sendEvent:event];
                }
                [event postNotification];
            }
            packet = MIDIPacketNext(packet);
        }
    }
}

static void AKMIDINotifyProc(const MIDINotification *message, void *refCon)
{
    AKMidi *m = (__bridge AKMidi *)refCon;

    @autoreleasepool {
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
                    NSLog(@"MIDI Notify, messageId=%@, size=%@", @(message->messageID), @(message->messageSize));
                break;
        }
    }
}

- (void)sendEvent:(AKMidiEvent *)event
{
    // Queue the event for submission to Csound
    @synchronized(_events) {
        [_events addObject:event];
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound MIDI callbacks
// -----------------------------------------------------------------------------


/* Csound MIDI read callback, called every k-cycle */
static int AKMidiDataRead(CSOUND *csound, void *userData,
                          unsigned char *mbuf, int nbytes)
{
    if (userData == nil)
        return 0;
    
    AKMidi *m = (__bridge AKMidi *)userData;
    int ret = 0;

    @autoreleasepool {
        @synchronized(m->_events) {
            AKMidiEvent *event;
            while (m->_events.count > 0) {
                event = m->_events[0];
                if (event.length > nbytes) { // Out of room in the buffer
                    break;
                }
                NSLog(@"%@", event);
                [event copyBytes:mbuf+ret];
                ret += event.length;
                nbytes -= event.length;
                [m->_events removeObjectAtIndex:0];
            }
        }
    }
    return ret;
}

/* Csound MIDI input open callback, sets the device for input */
static int AKMidiInDeviceOpen(CSOUND *csound, void **userData, const char *dev)
{
    AKMidi *m = [AKManager sharedManager].midi;
    NSCAssert(m, @"The AKMidi object is not yet available!");
    *userData = (__bridge void *)m;
    [m openMidiIn];
    return 0;
}

/* Csound close device callback */
static int AKMidiInDeviceClose(CSOUND *csound, void *userData)
{
    AKMidi *m = (__bridge AKMidi *)userData;
    [m closeMidiIn];
    return 0;
}

- (void)openMidiIn
{
    _inputs = MIDIGetNumberOfSources();
    NSLog(@"%@ MIDI sources\n", @(_inputs));
    
    if (!_client)
        MIDIClientCreate(CFSTR("CoreMIDI AudioKit"), AKMIDINotifyProc, (__bridge void *)self, &_client);
    if (!_inPort)
        MIDIInputPortCreate(_client, CFSTR("AK Input Port"), AKMIDIReadProc, (__bridge void *)self, &_inPort);
	
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

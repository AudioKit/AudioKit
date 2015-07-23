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
#import "csound.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CoreMIDI/MIDINetworkSession.h>
#endif

@implementation AKMidi
{
    MIDIClientRef _client;
    MIDIPortRef _inPort;
    CsoundObj *_csound;
    NSMutableArray *_events; // Buffer of pending events to send to Csound
}


#pragma mark - Initialization

- (instancetype)initWithCsound:(CsoundObj *)csound
{
    if(self = [super init]) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        MIDINetworkSession *session = [MIDINetworkSession defaultSession];
        session.enabled = YES;
        session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
#endif
        _csound = csound;
        _events = [NSMutableArray array];
        _forwardEvents = YES;
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - Broadcast MIDI Events
// -----------------------------------------------------------------------------

static void AKMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    AKMidi *m = (__bridge AKMidi *)refCon;
    
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	for (uint i=0; i < pktlist->numPackets; i++) {
        AKMidiEvent *event = [AKMidiEvent midiEventFromPacket:packet];
		
        if (m.forwardEvents) {
            [m sendEvent:event];
        }
        [event postNotification];
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
                NSLog(@"MIDI Notify, messageId=%@, size=%@", @(message->messageID), @(message->messageSize));
            break;
    }
}

- (void)sendEvent:(AKMidiEvent *)event
{
    // Queue the event for submission to Csound
    @synchronized(_events) {
        [_events addObject:event];
    }
}

/* csound MIDI read callback, called every k-cycle */
static int AKMidiDataRead(CSOUND *csound, void *userData,
                          unsigned char *mbuf, int nbytes)
{
    AKMidi *m = (__bridge AKMidi *)userData;

    int ret = 0;
    @synchronized(m->_events) {
        for(AKMidiEvent *event in m->_events) {
            NSData *data = event.bytes;
            // FIXME: Handle case when the provided buffer is too small
            [data getBytes:mbuf+ret];
            ret += data.length;
            nbytes -= data.length;
        }
        [m->_events removeAllObjects];
    }
    return ret;
}

- (void)openMidiIn
{
    _inputs = MIDIGetNumberOfSources();
    NSLog(@"%@ MIDI sources\n", @(_inputs));
    
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

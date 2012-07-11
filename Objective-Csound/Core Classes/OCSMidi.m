//
//  OCSMidi.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 7/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMidi.h"

void MidiPropertyReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon);

@interface OCSMidi() {
    NSMutableArray *midiProperties;
    MIDIClientRef mClient;
}
@end

@implementation OCSMidi
@synthesize midiProperties;

-(id)init
{
    if(self = [super init]) {
        midiProperties = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 128; i++) {
            [midiProperties addObject:[NSNull null]];
        }
        
    }
    return self;
}

/* coremidi callback, called when MIDI data is available */
void MidiPropertyReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon){
    //ARB - may want to transfer ownership to arc here, with __bridge_transfer
    OCSMidi* midi = (__bridge OCSMidi *)refcon;  
	MIDIPacket *packet = &((MIDIPacketList *)pktlist)->packet[0];
	Byte *curpack;
    int i, j;
	
	for (i = 0; i < pktlist->numPackets; i++) {
		for(j=0; j < packet->length; j+=3){
			curpack = packet->data+j;
            
			if ((*curpack++ | 0xB0) > 0) {
                unsigned int controllerNumber = (unsigned int)(*curpack++);
                unsigned int controllerValue = (unsigned int)(*curpack++);
                
                id midiProperty = [midi.midiProperties objectAtIndex:controllerNumber];
                
                NSLog(@"Controller Number: %d Value: %d", controllerNumber, controllerValue);
                
                if (midiProperty != [NSNull null]) {
                    //ARB - questionable cast here, but no generics in obj-c
                    [(OCSProperty *)midiProperty setValue:(Float32)controllerValue];
                }
            }      
		}
		packet = MIDIPacketNext(packet);
	} 
}

-(void)openMidiIn
{
    int k, endpoints;
    
    CFStringRef name = NULL, cname = NULL, pname = NULL;
    CFStringEncoding defaultEncoding = CFStringGetSystemEncoding();
    MIDIPortRef mport = NULL;
    MIDIEndpointRef endpoint;
    OSStatus ret;
	
    /* MIDI client */
    cname = CFStringCreateWithCString(NULL, "my client", defaultEncoding);
    ret = MIDIClientCreate(cname, NULL, NULL, &mClient);
    if(!ret){
        /* MIDI output port */
        pname = CFStringCreateWithCString(NULL, "outport", defaultEncoding);
        //ARB - check bridge
        ret = MIDIInputPortCreate(mClient, pname, MidiPropertyReadProc, (__bridge_retained void *)self, &mport);
        if(!ret){
            /* sources, we connect to all available input sources */
            endpoints = MIDIGetNumberOfSources();
			//NSLog(@"midi srcs %d\n", endpoints); 
            for(k=0; k < endpoints; k++){
                endpoint = MIDIGetSource(k);
                void *srcRefCon = endpoint;
                MIDIPortConnectSource(mport, endpoint, srcRefCon);
                
            }
        }
    }
    if(name) CFRelease(name);
    if(pname) CFRelease(pname);
    if(cname) CFRelease(cname); 
}

-(void)closeMidiIn
{
    MIDIClientDispose(mClient);
}

- (void)addProperty:(OCSProperty *)newProperty
{
    if ([newProperty isMidiEnabled]) {
        [midiProperties replaceObjectAtIndex:[newProperty midiChannel] withObject:newProperty];
    }

}

@end

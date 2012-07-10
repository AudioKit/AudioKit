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
void MidiWidgetsManagerReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon){
    OCSMidi* manager = (OCSMidi *)refcon;  
	MIDIPacket *packet = &((MIDIPacketList *)pktlist)->packet[0];
	Byte *curpack;
    int i, j;
	
	for (i = 0; i < pktlist->numPackets; i++) {
		for(j=0; j < packet->length; j+=3){
			curpack = packet->data+j;
            
			if ((*curpack++ | 0xB0) > 0) {
                unsigned int controllerNumber = (unsigned int)(*curpack++);
                unsigned int controllerValue = (unsigned int)(*curpack++);
                
                id midiProperty = [manager.widgetWrappers objectAtIndex:controllerNumber];
                
                //NSLog(@"Controller Number: %d Value: %d", controllerNumber, controllerValue);
                
                if (midiProperty != [NSNull null]) {
                    [(id<OCSProperty>)midiProperty setValue:(Float32)controllerValue];
                }
            }      
		}
		packet = MIDIPacketNext(packet);
	} 
}

-(void)openMidiIn
{}

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

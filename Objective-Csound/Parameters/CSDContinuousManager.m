//
//  CSDContinuousManager.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDContinuousManager.h"

void CSDContinuousManagerReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon);

@implementation CSDContinuousManager
@synthesize continuousParamList;

-(id)init {
    if(self = [super init]) {
        continuousParamList = [[NSMutableArray alloc] init];
        for (int i = 0; i<128; i++) {
            [continuousParamList addObject:[NSNull null]];
        }
        
    [self openMidiIn];
    }
    return self;
}

/*-(void)addContinuousParam:(CSDContinuous *)continuous forControllerNumber:(int)controllerNumber andChannelName:(NSString *)uniqueIdentifier
{
    if (controllerNumber < 0 || controllerNumber > 127) {
        NSLog(@"Error: Attempted to add a widget with controller number outside of range 0-127: %d", controllerNumber);
        return;
    }
    
    [continuousParamList replaceObjectAtIndex:controllerNumber withObject:continuous];
}*/

-(void)addContinuousParam:(CSDContinuous *)continuous
{
    [continuousParamList addObject:continuous];
    //[[CSDManager sharedCSDManager] addContinuousParam:continuous];
}

/* coremidi callback, called when MIDI data is available */
void CSDContinuousManagerReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon){
    CSDContinuousManager* manager = (__bridge CSDContinuousManager *)refcon;  
	MIDIPacket *packet = &((MIDIPacketList *)pktlist)->packet[0];
	Byte *curpack;
    int i, j;
	
	for (i = 0; i < pktlist->numPackets; i++) {
		for(j=0; j < packet->length; j+=3){
			curpack = packet->data+j;
            
			if ((*curpack++ | 0xB0) > 0) {
                unsigned int controllerNumber = (unsigned int)(*curpack++);
                unsigned int controllerValue = (unsigned int)(*curpack++);
                
                id param = [manager.continuousParamList objectAtIndex:controllerNumber];
                
                //NSLog(@"Controller Number: %d Value: %d", controllerNumber, controllerValue);
                
                if (param != [NSNull null]) {
                    //WORKING HERE: setMidiValue
                    //[(id<MidiWidgetWrapper>)wrapper setMIDIValue:controllerValue];
                }
            }
            
		}
		packet = MIDIPacketNext(packet);
	} 
    
}

#pragma mark CoreMidi Code
-(void)openMidiIn {
    int k, endpoints;
    
    CFStringRef name = NULL, cname = NULL, pname = NULL;
    CFStringEncoding defaultEncoding = CFStringGetSystemEncoding();
    MIDIPortRef mport = NULL;
    MIDIEndpointRef endpoint;
    OSStatus ret;
	
    /* MIDI client */
    cname = CFStringCreateWithCString(NULL, "my client", defaultEncoding);
    ret = MIDIClientCreate(cname, NULL, NULL, &myClient);
    if(!ret){
        /* MIDI output port */
        pname = CFStringCreateWithCString(NULL, "outport", defaultEncoding);
        ret = MIDIInputPortCreate(myClient, pname, CSDContinuousManagerReadProc, self, &mport);
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

-(void)closeMidiIn {
    MIDIClientDispose(myClient);
}

-(void)dealloc {
    [continuousParamList release];
    [super dealloc];
}

@end
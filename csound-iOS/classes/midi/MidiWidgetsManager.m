/* 
 
 MidiWidgetsManager.m:
 
 Copyright (C) 2011 Steven Yi
 
 This file is part of Csound for iOS.
 
 The Csound for iOS Library is free software; you can redistribute it
 and/or modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.   
 
 Csound is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with Csound; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307 USA
 
 */

#import "MidiWidgetsManager.h"
#import "SliderMidiWidgetWrapper.h"

void MidiWidgetsManagerReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon);

@implementation MidiWidgetsManager

@synthesize widgetWrappers = mWidgetWrappers;

-(id)init {
    if(self = [super init]) {
        mWidgetWrappers = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 128; i++) {
            [mWidgetWrappers addObject:[NSNull null]];
        }
        
    }
    return self;
}


-(void)addSlider:(UISlider*)slider forControllerNumber:(int)controllerNumber {
    SliderMidiWidgetWrapper* wrapper = [[SliderMidiWidgetWrapper alloc] init:slider];
    [self addMidiWidgetWrapper:wrapper forControllerNumber:controllerNumber];
}

-(void)addMidiWidgetWrapper:(id<MidiWidgetWrapper>)wrapper 
        forControllerNumber:(int)controllerNumber {

     if (controllerNumber < 0 || controllerNumber > 127) {
         NSLog(@"Error: Attempted to add a widget with controller number outside of range 0-127: %d", controllerNumber);
         return;
     }
    
    [mWidgetWrappers replaceObjectAtIndex:controllerNumber withObject:wrapper];
}


/* coremidi callback, called when MIDI data is available */
void MidiWidgetsManagerReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon){
    MidiWidgetsManager* manager = (MidiWidgetsManager *)refcon;  
	MIDIPacket *packet = &((MIDIPacketList *)pktlist)->packet[0];
	Byte *curpack;
    int i, j;
	
	for (i = 0; i < pktlist->numPackets; i++) {
		for(j=0; j < packet->length; j+=3){
			curpack = packet->data+j;

			if ((*curpack++ | 0xB0) > 0) {
                unsigned int controllerNumber = (unsigned int)(*curpack++);
                unsigned int controllerValue = (unsigned int)(*curpack++);
                
                id wrapper = [manager.widgetWrappers objectAtIndex:controllerNumber];
                
                //NSLog(@"Controller Number: %d Value: %d", controllerNumber, controllerValue);
                
                if (wrapper != [NSNull null]) {
                    [(id<MidiWidgetWrapper>)wrapper setMIDIValue:controllerValue];
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
    ret = MIDIClientCreate(cname, NULL, NULL, &mclient);
    if(!ret){
        /* MIDI output port */
        pname = CFStringCreateWithCString(NULL, "outport", defaultEncoding);
        ret = MIDIInputPortCreate(mclient, pname, MidiWidgetsManagerReadProc, self, &mport);
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
    MIDIClientDispose(mclient);
}

-(void)dealloc {
    [mWidgetWrappers release];
    [super dealloc];
}

@end

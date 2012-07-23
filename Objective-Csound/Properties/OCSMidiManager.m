//
//  OCSMidiManager.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMidiManager.h"

void OCSPropertyManagerReadProc(const MIDIPacketList *pktlist, void *refcon, void *srcConnRefCon);


@interface OCSMidiManager ()
{
    NSMutableArray *propertyList;
    MIDIClientRef myClient;
}
@end

@implementation OCSMidiManager
@synthesize propertyList;

/*
- (id)init {
    if(self = [super init]) {
        propertyList = [[NSMutableArray alloc] init];
        for (int i = 0; i<128; i++) {
            [propertyList addObject:[NSNull null]];
        }
        
    [self openMidiIn];
    }
    return self;
}
*/
- (void)addProperty:(OCSProperty *)property
forControllerNumber:(int)controllerNumber
{
    if (controllerNumber < 0 || controllerNumber > 127) {
        NSLog(@"Error: Attempted to add a widget with controller number outside of range 0-127: %d", controllerNumber);
        return;
    }
    
    [propertyList replaceObjectAtIndex:controllerNumber withObject:property];
}

/*
- (void)addProperty:(OCSProperty *)prop
{
    [propertyList addObject:prop];
    //[[OCSManager sharedOCSManager] addPropertyParam:prop];
}
*/


@end
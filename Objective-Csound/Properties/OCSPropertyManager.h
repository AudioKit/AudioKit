//
//  OCSPropertyManager.h
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  
//

#import <CoreMIDI/CoreMIDI.h>

#import "OCSManager.h"
#import "OCSProperty.h"

@interface OCSPropertyManager : NSObject
{
    NSMutableArray *propertyList;
    MIDIClientRef myClient;
}

@property (readonly) NSMutableArray* propertyList;

//- (void)openMidiIn;
//- (void)closeMidiIn;

////- (void)addProperty:(OCSProperty *)prop forControllerNumber:(int)controllerNumber andChannelName:(NSString *)uniqueIdentifier;

//- (void)addProperty:(OCSProperty *)prop;
@end
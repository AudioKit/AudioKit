//
//  CSDPropertyManager.h
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#import "CSDManager.h"
#import "CSDProperty.h"

@interface CSDPropertyManager : NSObject
{
    NSMutableArray * propertyList;
    MIDIClientRef myClient;
}

@property (readonly) NSMutableArray* propertyList;

-(void)openMidiIn;
-(void)closeMidiIn;

//-(void)addProperty:(CSDProperty *)prop forControllerNumber:(int)controllerNumber andChannelName:(NSString *)uniqueIdentifier;

-(void)addProperty:(CSDProperty *)prop;
@end
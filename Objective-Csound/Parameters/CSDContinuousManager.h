//
//  CSDContinuousManager.h
//  ExampleProject
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
#import "CSDContinuous.h"

@interface CSDContinuousManager : NSObject
{
    NSMutableArray * continuousParamList;
    MIDIClientRef myClient;
}

@property (readonly) NSMutableArray* continuousParamList;

-(void)openMidiIn;
-(void)closeMidiIn;

-(void)addContinuousParam:(CSDContinuous *)continuous forControllerNumber:(int)controllerNumber andChannelName:(NSString *)uniqueIdentifier;

@end
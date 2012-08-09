//
//  OCSMidiManager.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  
//
#import <CoreMIDI/CoreMIDI.h>
#import "OCSInstrumentProperty.h"

/** This class handles MIDI Properties.
 */

@interface OCSMidiManager : NSObject

/// List of properties handled by the MIDI Manager
@property (readonly) NSMutableArray* propertyList;

/// Associates a property with a controller number
/// @param property         The property that will be set with MIDI
/// @param controllerNumber The channel on which the MIDI information will be received.
- (void)addProperty:(OCSInstrumentProperty *)property 
forControllerNumber:(int)controllerNumber;

//- (void)addProperty:(OCSInstrumentProperty *)prop;
@end
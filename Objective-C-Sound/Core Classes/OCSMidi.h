//
//  OCSMidi.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 7/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "OCSInstrumentProperty.h"

/** This class handles all MIDI interaction in Objective-C Sound.
 */

@interface OCSMidi : NSObject

/// All the properties available to associate with midi
@property (readonly) NSMutableArray *midiProperties;

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

/// Add a midi enabled Property to be updated by midi client.
/// @param newProperty Midi enabled OCSProperty to add to midi callbacks.
- (void)addProperty:(OCSInstrumentProperty *)newProperty;

@end

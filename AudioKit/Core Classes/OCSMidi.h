//
//  OCSMidi.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMidiListener.h"

/** OCSMidi is the object that handles the MIDI input and output from OCS.
 */

@interface OCSMidi : NSObject

/// A set of all listeners "subscribed" to MIDI Messages.
@property (nonatomic, strong) NSMutableSet *listeners;

/// Add listener to a list of notified listeners
/// @param listener Object that implements the OCSMidiListener protocol
- (void)addListener:(id<OCSMidiListener>)listener;

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

@end

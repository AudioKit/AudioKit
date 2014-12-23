//
//  AKMidi.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKMidiListener.h"

/** AKMidi is the object that handles the MIDI input and output from AK.
 */

@interface AKMidi : NSObject

/// A set of all listeners "subscribed" to MIDI Messages.
@property (nonatomic, strong) NSMutableSet *listeners;

/// Add listener to a list of notified listeners
/// @param listener Object that implements the AKMidiListener protocol
- (void)addListener:(id<AKMidiListener>)listener;

/// Create midi client and connect to all available midi input sources.
- (void)openMidiIn;

/// Dispose of midi client.
- (void)closeMidiIn;

@end

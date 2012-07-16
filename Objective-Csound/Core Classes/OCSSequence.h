//
//  OCSSequence.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"

/** A sequence is a chain of events.
 */

@interface OCSSequence : NSObject

/// The array of events contained in the sequence.
@property (nonatomic, strong) NSMutableArray *events;
/// The start times for all the events in the sequence.
@property (nonatomic, strong) NSMutableArray *times;

/// Trigger playback of the sequence.
- (void)play;

/// Add Event In Next Available Spot
/// @param event Event to be added either at the beginning, or after the last event is finished
- (void)addEvent:(OCSEvent *)event;

/// Add Event In Next Available Spot
/// @param event          Event to be added at the specified time.
/// @param timeSinceStart Exact time at which the event will be trigger relative to the start of the sequence.
- (void)addEvent:(OCSEvent *)event 
          atTime:(float)timeSinceStart;

// More helpers to add

//- (void)addSimultaneousEvent:(OCSEvent *)event;
//- (void)addNextEvent:(OCSEvent *)event;

//- (void)addEvent:(OCSEvent *)event 
//   afterDuration:(float)timeSinceLastEventStarted;

@end

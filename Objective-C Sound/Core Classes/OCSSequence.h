//
//  OCSSequence.h
//  Objective-C Sound
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

/// Stop playback of the sequence.
- (void)stop;

/// Add event In next available spot
/// @param event Event to be added either at the beginning, or at the same time as the last event
- (void)addEvent:(OCSEvent *)event;

/// Add event at a specific time
/// @param event          Event to be added at the specified time.
/// @param timeSinceStart Exact time at which the event will be trigger relative to the start of the sequence.
- (void)addEvent:(OCSEvent *)event 
          atTime:(float)timeSinceStart;

/// Add event a specific time after the last event started
/// @param event                     Event to be added at the specified time.
/// @param timeSinceLastEventStarted Amount of time after the last event, when the event will be triggered.
- (void)addEvent:(OCSEvent *)event 
   afterDuration:(float)timeSinceLastEventStarted;

@end

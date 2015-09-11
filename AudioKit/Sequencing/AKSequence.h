//
//  AKSequence.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKEvent.h"

/** A sequence is a chain of events.
 */

@interface AKSequence : NSObject

/// The array of events contained in the sequence.
@property NSMutableArray<AKEvent *> *events;

/// The start times for all the events in the sequence.
@property NSMutableArray<NSNumber *> *times;

/// Class-level initializer for empty sequence
+ (AKSequence *)sequence;

/// Trigger playback of the sequence.
- (void)play;

/// Loop playback of the sequence.
/// @param loopDuration Total time of one run of the loop
- (void)loopWithLoopDuration:(float)loopDuration;

/// Pause playback of the sequence.
- (void)pause;

/// Stop playback of the sequence, stopping all the notes in the sequence.
- (void)stop;

/// Removes all events from the sequence
- (void)reset;

/// Add event In next available spot
/// @param event Event to be added either at the beginning, or at the same time as the last event
- (void)addEvent:(AKEvent *)event;

/// Add event at a specific time
/// @param event          Event to be added at the specified time.
/// @param timeSinceStart Exact time at which the event will be trigger relative to the start of the sequence.
- (void)addEvent:(AKEvent *)event 
          atTime:(float)timeSinceStart;

/// Add event a specific time after the last event started
/// @param event                     Event to be added at the specified time.
/// @param timeSinceLastEventStarted Amount of time after the last event, when the event will be triggered.
- (void)addEvent:(AKEvent *)event 
   afterDuration:(float)timeSinceLastEventStarted;

@end

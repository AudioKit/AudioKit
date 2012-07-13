//
//  OCSSequence.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"

@interface OCSSequence : NSObject

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *times;

- (id)initWithOrchestra:(OCSOrchestra *)orchestra;
- (void)play;
/// Add Event In Next Available Spot
/// @param event Event to be added either at the beginning, or after the last event is finished
- (void)addEvent:(OCSEvent *)event;

- (void)addEvent:(OCSEvent *)event 
          atTime:(float)timeSinceStart;

// More helpers to add

//- (void)addSimultaneousEvent:(OCSEvent *)event;
//- (void)addNextEvent:(OCSEvent *)event;

//- (void)addEvent:(OCSEvent *)event 
//   afterDuration:(float)timeSinceLastEventStarted;

@end

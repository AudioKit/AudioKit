//
//  OCSSequence.m
//  Objective-Csound
//
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSequence.h"
#import "OCSManager.h"

@interface OCSSequence () {
    NSMutableArray *events;
    NSMutableArray *times;
    NSTimer *timer;
    int index;
}
@end

@implementation OCSSequence

@synthesize events, times;

- (id) init {
    self = [super init];
    if (self) {
        events = [[NSMutableArray alloc] init];
        times  = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addEvent:(OCSEvent *)event 
{
    [events addObject:event];
    NSNumber *time = [NSNumber numberWithFloat:0.0];
    if ([times count] > 0) {
        //OCSEvent *lastEvent = [events lastObject];
        time = [NSNumber numberWithFloat:([[times lastObject] floatValue] + 1.0)];
    }
    [times addObject:time];
    //NSLog(@"Added an event at time %g, count is now up to %i", [time floatValue], [events count]);
}



- (void)addEvent:(OCSEvent *)event 
          atTime:(float)timeSinceStart;
{
    [events addObject:event];
    NSNumber *time = [NSNumber numberWithFloat:timeSinceStart];
    [times addObject:time];
}

-(void) play
{
    index = 0;
    [self playNextEventInSequence:timer];
}


- (void)playNextEventInSequence:(NSTimer *)aTimer;
{
    OCSEvent *event = [events objectAtIndex:index];
    [[OCSManager sharedOCSManager] playEvent:event];

    if (index < [times count]-1 ) {
        float timeUntilNextEvent = [[times objectAtIndex:index+1] floatValue] - [[times objectAtIndex:index] floatValue];
        
        //NSLog(@"Next event in %f, times left %i", timeUntilNextEvent, [times count] - index);
        timer = [NSTimer scheduledTimerWithTimeInterval:timeUntilNextEvent
                                                 target:self 
                                               selector:@selector(playNextEventInSequence:) 
                                               userInfo:nil 
                                                repeats:NO];
        index++;

    }
}


@end

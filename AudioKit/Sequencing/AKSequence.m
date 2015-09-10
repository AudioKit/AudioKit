//
//  AKSequence.m
//  AudioKit
//
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSequence.h"
#import "AKManager.h"

@implementation AKSequence
{
    BOOL isPlaying;
    unsigned int index;
    float _loopDuration;
}

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

- (instancetype)init
{
    self = [super init];
    if (self) {
        _events = [[NSMutableArray alloc] init];
        _times  = [[NSMutableArray alloc] init];
        isPlaying = NO;
        _loopDuration = 0;
    }
    return self;
}

+ (AKSequence *)sequence
{
    return [[self alloc] init];
}

- (void)addEvent:(AKEvent *)event
{
    [self addEvent:event afterDuration:0.0f];
}

- (void)addEvent:(AKEvent *)event
          atTime:(float)timeSinceStart
{
    NSNumber *time = @(timeSinceStart);
    
    int insertionIndex = 0;
    BOOL doInsertion = NO;
    for (NSNumber *t in _times) {
        if (t.floatValue > timeSinceStart) {
            doInsertion = YES;
            break;
        }
        insertionIndex++;
    }
    if (doInsertion) {
        [_events insertObject:event atIndex:insertionIndex];
        [_times  insertObject:time  atIndex:insertionIndex];
    } else {
        [_events addObject:event];
        [_times addObject:time];
    }
}

- (void)addEvent:(AKEvent *)event
   afterDuration:(float)timeSinceLastEventStarted
{
    [_events addObject:event];
    NSNumber *time = @0.0F;
    if ([_times count] > 0) {
        //AKEvent *lastEvent = [_events lastObject];
        time = [NSNumber numberWithFloat:([[_times lastObject] floatValue] + timeSinceLastEventStarted)];
    }
    [_times addObject:time];
}

// -----------------------------------------------------------------------------
#  pragma mark - Sequence Playback Control
// -----------------------------------------------------------------------------

- (void)play
{
    index = 0;
    isPlaying = YES;
    
    // Delay playback until first event is set to start.
    [self performSelector:@selector(playNextEventInSequence)
               withObject:nil
               afterDelay:[_times[0] floatValue]
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)loopWithLoopDuration:(float)loopDuration
{
    index = 0;
    isPlaying = YES;
    _loopDuration = loopDuration;
    
    // Delay playback until first event is set to start.
    [self performSelector:@selector(playNextEventInLoop)
               withObject:nil
               afterDelay:[_times[0] floatValue]
                  inModes:@[NSRunLoopCommonModes]];
}

- (void)pause
{
    isPlaying = NO;
}

- (void)stop
{
    isPlaying = NO;
}

- (void)reset
{
    [_events removeAllObjects];
    [_times  removeAllObjects];
    isPlaying = NO;
}


// Cue up the next event to be triggered.
- (void)playNextEventInSequence
{
    if (isPlaying) {
        AKEvent *event = _events[index];
        [[AKManager sharedManager] triggerEvent:event];
    }
    
    if (index < [_times count]-1 && isPlaying) {
        float timeUntilNextEvent = [_times[index+1] floatValue] - [_times[index] floatValue];
        [self performSelector:@selector(playNextEventInSequence)
                   withObject:nil
                   afterDelay:timeUntilNextEvent
                      inModes:@[NSRunLoopCommonModes]];
    }
    index++;
}

- (void)playNextEventInLoop
{
    if (isPlaying) {
        AKEvent *event = _events[index];
        [[AKManager sharedManager] triggerEvent:event];
    }
    
    if (isPlaying) {
        
        float timeUntilNextEvent = 0;
        if (index < [_times count]-1) {
            timeUntilNextEvent = [_times[index+1] floatValue] - [_times[index] floatValue];
        }
        if (timeUntilNextEvent <= 0) {
            timeUntilNextEvent += _loopDuration;
        }
        [self performSelector:@selector(playNextEventInLoop)
                   withObject:nil
                   afterDelay:timeUntilNextEvent
                      inModes:@[NSRunLoopCommonModes]];
    }
    index++;
    index = index % [_times count];
}


@end

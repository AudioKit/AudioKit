//
//  AKPhrase.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 12/12/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKPhrase.h"
#import "AKNote.h"
#import "AKInstrument.h"
#import "AKManager.h"

@interface AKPhrase() {
    NSMutableArray *_timeStartNotePairs;
    NSMutableArray *_timeStopNotePairs;
    NSMutableArray *_timeUpdateNotePropertyTriplets;
}
@end

@implementation AKPhrase

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

+ (AKPhrase *)phrase
{
    return [[self alloc] init];
}

- (NSUInteger)count
{
    return  [_timeStartNotePairs count] +
            [_timeStopNotePairs count] +
            [_timeUpdateNotePropertyTriplets count];
}

- (float)duration
{
    float lastTime = [[_timeStartNotePairs lastObject][0] floatValue];
    AKNote *lastNote = [_timeStartNotePairs lastObject][1];
    float durationBasedTime = lastTime + lastNote.duration.value;
    float stoppageBasedTime = [[_timeStopNotePairs lastObject][0] floatValue];
    
    float duration = durationBasedTime;
    if (durationBasedTime < stoppageBasedTime) duration = stoppageBasedTime;
    return duration;
}

- (void)reset
{
    _timeStartNotePairs = [[NSMutableArray alloc] init];
    _timeStopNotePairs  = [[NSMutableArray alloc] init];
    _timeUpdateNotePropertyTriplets = [[NSMutableArray alloc] init];
}

- (void)addNote:(AKNote *)note
{
    [self startNote:note atTime:0];
}

- (void)addNote:(AKNote *)note atTime:(float)time
{
    [self startNote:note atTime:time];
}

- (void)startNote:(AKNote *)note atTime:(float)time
{
    NSNumber *startTime = [NSNumber numberWithFloat:time];
    [_timeStartNotePairs addObject:@[startTime, note]];
}

- (void)stopNote:(AKNote *)note atTime:(float)time
{
    NSNumber *stopTime = [NSNumber numberWithFloat:time];
    [_timeStopNotePairs addObject:@[stopTime, note]];
}

- (void)updateNoteProperty:(AKNoteProperty *)noteProperty
                 withValue:(float)value
                    atTime:(float)time
{
    NSNumber *updateTime = [NSNumber numberWithFloat:time];
    NSNumber *newValue = [NSNumber numberWithFloat:value];
    [_timeUpdateNotePropertyTriplets addObject:@[updateTime, noteProperty, newValue]];
}

- (void)playUsingInstrument:(AKInstrument *)instrument
{
    [[AKManager sharedManager] startBatch];
    for (NSArray *timeStartNotePair in _timeStartNotePairs) {
        float time = [timeStartNotePair[0] floatValue];
        AKNote *note = timeStartNotePair[1];
        [instrument playNote:note afterDelay:time];
    }
    for (NSArray *timeStopNotePair in _timeStopNotePairs) {
        float time = [timeStopNotePair[0] floatValue];
        AKNote *note = timeStopNotePair[1];
        [instrument stopNote:note afterDelay:time];
    }
    for (NSArray *timeUpdateNotePropertyTriplet in _timeUpdateNotePropertyTriplets) {
        float time = [timeUpdateNotePropertyTriplet[0] floatValue];
        AKNoteProperty *noteProperty = timeUpdateNotePropertyTriplet[1];
        float newValue = [timeUpdateNotePropertyTriplet[2] floatValue];
        [noteProperty setValue:newValue afterDelay:time];
    }
    [[AKManager sharedManager] endBatch];
}




@end

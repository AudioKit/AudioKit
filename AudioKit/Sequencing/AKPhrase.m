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
    NSMutableArray *timeStartNotePairs;
    NSMutableArray *timeStopNotePairs;
    NSMutableArray *timeUpdateNotePropertyTriplets;
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

- (int)count
{
    return
    (int)[timeStartNotePairs count] +
    (int)[timeStopNotePairs count] +
    (int)[timeUpdateNotePropertyTriplets count];
}

- (float)duration
{
    float lastTime = [[[timeStartNotePairs lastObject] objectAtIndex:0] floatValue];
    AKNote *lastNote = [[timeStartNotePairs lastObject] objectAtIndex:1];
    float durationBasedTime = lastTime + lastNote.duration.value;
    float stoppageBasedTime = [[[timeStopNotePairs lastObject] objectAtIndex:0] floatValue];
    
    float duration = durationBasedTime;
    if (durationBasedTime < stoppageBasedTime) duration = stoppageBasedTime;
    return duration;
}

- (void)reset
{
    timeStartNotePairs = [[NSMutableArray alloc] init];
    timeStopNotePairs  = [[NSMutableArray alloc] init];
    timeUpdateNotePropertyTriplets = [[NSMutableArray alloc] init];
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
    [timeStartNotePairs addObject:@[startTime, note]];
}

- (void)stopNote:(AKNote *)note atTime:(float)time
{
    NSNumber *stopTime = [NSNumber numberWithFloat:time];
    [timeStopNotePairs addObject:@[stopTime, note]];
}

- (void)updateNoteProperty:(AKNoteProperty *)noteProperty
                 withValue:(float)value
                    atTime:(float)time
{
    NSNumber *updateTime = [NSNumber numberWithFloat:time];
    NSNumber *newValue = [NSNumber numberWithFloat:value];
    [timeUpdateNotePropertyTriplets addObject:@[updateTime, noteProperty, newValue]];
}

- (void)playUsingInstrument:(AKInstrument *)instrument
{
    [[AKManager sharedManager] startBatch];
    for (NSArray *timeStartNotePair in timeStartNotePairs) {
        float time = [[timeStartNotePair objectAtIndex:0] floatValue];
        AKNote *note = (AKNote *)[timeStartNotePair objectAtIndex:1];
        [instrument playNote:note afterDelay:time];
    }
    for (NSArray *timeStopNotePair in timeStopNotePairs) {
        float time = [[timeStopNotePair objectAtIndex:0] floatValue];
        AKNote *note = (AKNote *)[timeStopNotePair objectAtIndex:1];
        [instrument stopNote:note afterDelay:time];
    }
    for (NSArray *timeUpdateNotePropertyTriplet in timeUpdateNotePropertyTriplets) {
        float time = [[timeUpdateNotePropertyTriplet objectAtIndex:0] floatValue];
        AKNoteProperty *noteProperty = (AKNoteProperty *)[timeUpdateNotePropertyTriplet objectAtIndex:1];
        float newValue = [[timeUpdateNotePropertyTriplet objectAtIndex:2] floatValue];
        [noteProperty setValue:newValue afterDelay:time];
    }
    [[AKManager sharedManager] endBatch];
}




@end

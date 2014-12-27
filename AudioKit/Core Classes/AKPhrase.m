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

@interface AKPhrase() {
    NSMutableArray *timeNotePairs;
}
@end

@implementation AKPhrase

- (instancetype)init
{
    self = [super init];
    if (self) {
        timeNotePairs = [[NSMutableArray alloc] init];
    }
    return self;

}

- (void)addNote:(AKNote *)note
{
    [timeNotePairs addObject:@[@0, note]];
}
- (void)addNote:(AKNote *)note atTime:(float)time
{
    NSNumber *startTime = [NSNumber numberWithFloat:time];
    [timeNotePairs addObject:@[startTime, note]];
}

- (void)playUsingInstrument:(AKInstrument *)instrument
{
    for (NSArray *timeNotePair in timeNotePairs) {
        float time = [(NSNumber *)[timeNotePair objectAtIndex:0] floatValue];
        AKNote *note = (AKNote *)[timeNotePair objectAtIndex:1];
        [instrument playNote:note afterDelay:time];
    }
}




@end

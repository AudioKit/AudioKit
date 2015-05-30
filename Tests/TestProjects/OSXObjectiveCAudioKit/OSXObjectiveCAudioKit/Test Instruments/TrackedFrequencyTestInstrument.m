//
//  TrackedFrequencyTestInstrument.m
//  OSXObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/20/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "TrackedFrequencyTestInstrument.h"

@implementation TrackedFrequencyTestInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Instrument Properties
        _trackedFrequency = [self createPropertyWithValue:0.0 minimum:0.0 maximum:100000.0];
        
        AKLine *frequencyLine = [[AKLine alloc] initWithFirstPoint:akp(200)
                                                       secondPoint:akp(2000)
                                             durationBetweenPoints:akp(1)];
        
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = frequencyLine;
        
        AKTrackedFrequency *tracker = [[AKTrackedFrequency alloc] initWithInput:oscillator
                                                                     sampleSize:akp(512)];
        AKAssignment *assignment = [[AKAssignment alloc] initWithOutput:_trackedFrequency input:tracker];
        [self connect:assignment];
        [self enableParameterLog:@"AKTEST" parameter:tracker timeInterval:0.01];
    }
    return self;
}

@end

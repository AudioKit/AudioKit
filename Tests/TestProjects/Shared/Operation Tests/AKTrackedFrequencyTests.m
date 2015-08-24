//
//  AKTrackedFrequencyTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestTrackedFrequencyInstrument : AKInstrument
@end

@implementation TestTrackedFrequencyInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKLine *frequencyLine = [[AKLine alloc] initWithFirstPoint:akp(110)
                                                       secondPoint:akp(880)
                                             durationBetweenPoints:akp(testDuration)];


        AKOscillator *frequencyDeviation = [AKOscillator oscillator];
        frequencyDeviation.frequency = akp(1);
        frequencyDeviation.amplitude = akp(30);

        AKOscillator *sine = [AKOscillator oscillator];
        sine.frequency = [frequencyLine plus:frequencyDeviation];

        AKTrackedFrequency *tracker = [[AKTrackedFrequency alloc] initWithInput:sine
                                                                     sampleSize:akp(512)];

        AKOscillator *trackedSine = [AKOscillator oscillator];
        trackedSine.frequency = tracker;

        AKStereoAudio *output = [[AKStereoAudio alloc] initWithLeftAudio:sine rightAudio:trackedSine];

        [self setStereoAudioOutput:output];
    }
    return self;
}

@end

@interface AKTrackedFrequencyTests : AKTestCase
@end

@implementation AKTrackedFrequencyTests

- (void)testTrackedFrequency
{
    // Set up performance
    TestTrackedFrequencyInstrument *testInstrument = [[TestTrackedFrequencyInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"3bb1ff85a24195d89ce2df34e0c78709");
}

@end

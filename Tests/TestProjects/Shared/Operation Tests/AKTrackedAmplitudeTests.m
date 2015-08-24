//
//  AKTrackedAmplitudeTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestTrackedAmplitudeInstrument : AKInstrument
@end

@implementation TestTrackedAmplitudeInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKOscillator *amplitudeDeviation = [AKOscillator oscillator];
        amplitudeDeviation.frequency = akp(1.5);
        amplitudeDeviation.amplitude = akp(0.5);

        AKOscillator *sine = [AKOscillator oscillator];
        sine.amplitude = [akp(0.5) plus:amplitudeDeviation];

        AKTrackedAmplitude *tracker = [[AKTrackedAmplitude alloc] initWithInput:sine];

        AKOscillator *trackedSine = [AKOscillator oscillator];
        trackedSine.amplitude = tracker;

        AKStereoAudio *output = [[AKStereoAudio alloc] initWithLeftAudio:sine rightAudio:trackedSine];

        [self setStereoAudioOutput:output];
    }
    return self;
}

@end

@interface AKTrackedAmplitudeTests : AKTestCase
@end

@implementation AKTrackedAmplitudeTests

- (void)testTrackedAmplitude
{
    // Set up performance
    TestTrackedAmplitudeInstrument *testInstrument = [[TestTrackedAmplitudeInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"e1d7e60d0a8ceafc835670edf4367bdf");
}

@end


//
//  AKLowFrequencyOscillatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestLowFrequencyOscillatorInstrument : AKInstrument
@end

@implementation TestLowFrequencyOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKLowFrequencyOscillator *control = [AKLowFrequencyOscillator oscillator];
        control.waveformType = [AKLowFrequencyOscillator waveformTypeForSawtooth];
        control.amplitude = akp(100);
        control.frequency = akp(2);

        AKLowFrequencyOscillator *lowFrequencyOscillator = [AKLowFrequencyOscillator oscillator];
        lowFrequencyOscillator.waveformType = [AKLowFrequencyOscillator waveformTypeForTriangle];
        lowFrequencyOscillator.frequency = [control plus:akp(100)];

        [self setAudioOutput:lowFrequencyOscillator];
    }
    return self;
}

@end

@interface AKLowFrequencyOscillatorTests : AKTestCase
@end

@implementation AKLowFrequencyOscillatorTests

- (void)testLowFrequencyOscillator
{
    // Set up performance
    TestLowFrequencyOscillatorInstrument *testInstrument = [[TestLowFrequencyOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"a1d56d1ce56c3f8e2238db0b5f2e2dcf");
}

@end

//
//  AKInterpolatedRandomNumberPulseTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestInterpolatedRandomNumberPulseInstrument : AKInstrument
@end

@implementation TestInterpolatedRandomNumberPulseInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKInterpolatedRandomNumberPulse *pulse = [AKInterpolatedRandomNumberPulse pulse];
        pulse.frequency = akp(3);

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = [pulse scaledBy:akp(4000)];

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKInterpolatedRandomNumberPulseTests : AKTestCase
@end

@implementation AKInterpolatedRandomNumberPulseTests

- (void)testInterpolatedRandomNumberPulse
{
    // Set up performance
    TestInterpolatedRandomNumberPulseInstrument *testInstrument = [[TestInterpolatedRandomNumberPulseInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"996dd813043fd0556224cde3bb224085");
}

@end

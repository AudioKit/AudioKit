//
//  AKBalanceTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestBalanceInstrument : AKInstrument
@end

@implementation TestBalanceInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKOscillator *amplitude = [AKOscillator oscillator];
        amplitude.frequency = akp(1);

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.amplitude = amplitude;

        AKFMOscillator *synth = [AKFMOscillator oscillator];
        AKBalance *balance = [[AKBalance alloc] initWithInput:synth comparatorAudioSource:oscillator];

        [self setAudioOutput:balance];
    }
    return self;
}

@end

@interface AKBalanceTests : AKTestCase
@end

@implementation AKBalanceTests

- (void)testBalance
{
    // Set up performance
    TestBalanceInstrument *testInstrument = [[TestBalanceInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"0c99d19bc533ca46822bd82995a7d73b");
}

@end

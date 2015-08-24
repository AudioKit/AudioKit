//
//  AKOscillatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestOscillatorInstrument : AKInstrument
@end

@implementation TestOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKOscillator *frequencyOscillator = [AKOscillator oscillator];
        frequencyOscillator.frequency = akp(2);

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = [[frequencyOscillator scaledBy:akp(110)] plus:akp(440)];

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKOscillatorTests : AKTestCase
@end

@implementation AKOscillatorTests

- (void)testOscillator
{
    // Set up performance
    TestOscillatorInstrument *testInstrument = [[TestOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"95184436da24aa6c7b65b80b48f916e8");
}

@end

//
//  AKJitterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestJitterInstrument : AKInstrument
@end

@implementation TestJitterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKJitter *jitter = [AKJitter jitter];
        jitter.amplitude = akp(3000);

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = jitter;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKJitterTests : AKTestCase
@end

@implementation AKJitterTests

- (void)testJitter
{
    // Set up performance
    TestJitterInstrument *testInstrument = [[TestJitterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"57be4e735c6d3d830569570e8163881b");
}

@end

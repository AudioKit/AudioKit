//
//  AKSegmentArrayLoopTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestSegmentArrayLoopInstrument : AKInstrument
@end

@implementation TestSegmentArrayLoopInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKSegmentArrayLoop *segmentLoop = [[AKSegmentArrayLoop alloc] initWithFrequency:akp(1)
                                                                           initialValue:akp(440)];
        [segmentLoop addValue:akp(550) afterDuration:akp(1) concavity:akp(-5)];
        [segmentLoop addValue:akp(330) afterDuration:akp(2) concavity:akp(0)];
        [segmentLoop addValue:akp(440) afterDuration:akp(1) concavity:akp(5)];


        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = segmentLoop;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKSegmentArrayLoopTests : AKTestCase
@end

@implementation AKSegmentArrayLoopTests

- (void)testSegmentArrayLoop
{
    // Set up performance
    TestSegmentArrayLoopInstrument *testInstrument = [[TestSegmentArrayLoopInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"6bb8a3223645a51b50b0ccc9fb832a28");
}

@end

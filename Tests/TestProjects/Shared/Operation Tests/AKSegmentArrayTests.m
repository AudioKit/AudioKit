//
//  AKSegmentArrayTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestSegmentArrayInstrument : AKInstrument
@end

@implementation TestSegmentArrayInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKSegmentArray *segments = [[AKSegmentArray alloc] initWithInitialValue:akp(440)
                                                                    targetValue:akp(660)
                                                                  afterDuration:akp(2)
                                                                      concavity:akp(3)];
        [segments addValue:akp(550) afterDuration:akp(0) concavity:akp(0)];
        [segments addValue:akp(550) afterDuration:akp(1) concavity:akp(0)];
        [segments addValue:akp(880) afterDuration:akp(0) concavity:akp(0)];
        [segments addValue:akp(220) afterDuration:akp(6) concavity:akp(-5)];
        [segments addValue:akp(220) afterDuration:akp(1) concavity:akp(0)];


        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = segments;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKSegmentArrayTests : AKTestCase
@end

@implementation AKSegmentArrayTests

- (void)testSegmentArray
{
    // Set up performance
    TestSegmentArrayInstrument *testInstrument = [[TestSegmentArrayInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"d4a76f28b8d87079bb87448d1c14daca");
}

@end

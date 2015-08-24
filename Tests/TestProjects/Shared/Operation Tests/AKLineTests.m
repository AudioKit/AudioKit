//
//  AKLineTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestLineInstrument : AKInstrument
@end

@implementation TestLineInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKLine *line = [[AKLine alloc] init];
        line.secondPoint = akp(100);

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = line;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKLineTests : AKTestCase
@end

@implementation AKLineTests

- (void)testLine
{
    // Set up performance
    TestLineInstrument *testInstrument = [[TestLineInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"bb6c59ff9937cf4b0af5b110493aabc6");
}

@end

//
//  AKLinearEnvelopeTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 2.0

@interface TestLinearEnvelopeInstrument : AKInstrument
@end

@implementation TestLinearEnvelopeInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKLinearEnvelope *envelope = [AKLinearEnvelope envelope];
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.amplitude = envelope;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKLinearEnvelopeTests : AKTestCase
@end

@implementation AKLinearEnvelopeTests

- (void)testLinearEnvelope
{
    // Set up performance
    TestLinearEnvelopeInstrument *testInstrument = [[TestLinearEnvelopeInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKNote *note = [[AKNote alloc] init];
    note.duration.value = 1.0;
    [testInstrument playNote:note];


    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"c55ce40cbaf82ff8b25f8afa29d805bc");
}

@end

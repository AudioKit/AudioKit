//
//  AKLinearADSREnvelopeTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestLinearADSREnvelopeInstrument : AKInstrument
@end

@implementation TestLinearADSREnvelopeInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKLinearADSREnvelope *adsr = [AKLinearADSREnvelope envelope];
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.amplitude = adsr;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKLinearADSREnvelopeTests : AKTestCase
@end

@implementation AKLinearADSREnvelopeTests

- (void)testLinearADSREnvelope
{
    // Set up performance
    TestLinearADSREnvelopeInstrument *testInstrument = [[TestLinearADSREnvelopeInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    AKNote *note1 = [[AKNote alloc] init];
    AKNote *note2 = [[AKNote alloc] init];

    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note1 atTime:0.5];
    [phrase stopNote:note1 atTime:2.5];
    note2.duration.value = 5.0;
    [phrase addNote:note2 atTime:3.5];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"d3d30e50ddd2949ed70e11923ac9294f");
}

@end

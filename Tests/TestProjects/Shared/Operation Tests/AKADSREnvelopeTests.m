//
//  AKADSREnvelopeTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestADSREnvelopeInstrument : AKInstrument
@end

@implementation TestADSREnvelopeInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKADSREnvelope *adsr = [AKADSREnvelope envelope];
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.amplitude = adsr;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKADSREnvelopeTests : AKTestCase
@end

@implementation AKADSREnvelopeTests

- (void)testADSREnvelope
{
    // Set up performance
    TestADSREnvelopeInstrument *testInstrument = [[TestADSREnvelopeInstrument alloc] init];
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
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"1ec9b44e7341e2ced1e50279da94a84e");
}

@end

//
//  AKPortamentoTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestPortamentoInstrument : AKInstrument
@end

@implementation TestPortamentoInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKLowFrequencyOscillator *frequencyShifter = [AKLowFrequencyOscillator oscillator];
        frequencyShifter.waveformType = [AKLowFrequencyOscillator waveformTypeForBipolarSquare];
        frequencyShifter.amplitude = akp(100);
        frequencyShifter.frequency = akp(0.25);

        AKPortamento *portamento = [[AKPortamento alloc] initWithInput:frequencyShifter];

        AKOscillator *sine = [AKOscillator oscillator];
        sine.frequency = [akp(880) plus:portamento];

        [self setAudioOutput:sine];
    }
    return self;
}

@end

@interface AKPortamentoTests : AKTestCase
@end

@implementation AKPortamentoTests

- (void)testPortamento
{
    // Set up performance
    TestPortamentoInstrument *testInstrument = [[TestPortamentoInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"4640b47005f3ff32aeab0a1da349da4c");
}

@end

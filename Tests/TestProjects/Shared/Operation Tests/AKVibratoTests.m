//
//  AKVibratoTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestVibratoInstrument : AKInstrument
@end

@implementation TestVibratoInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        AKVibrato *vibrato = [AKVibrato vibrato];
        vibrato.averageAmplitude = akp(20);

        AKOscillator *sine = [AKOscillator oscillator];
        sine.frequency = [akp(440) plus:vibrato];

        [self setAudioOutput:sine];
    }
    return self;
}

@end

@interface AKVibratoTests : AKTestCase
@end

@implementation AKVibratoTests

- (void)testVibrato
{
    // Set up performance
    TestVibratoInstrument *testInstrument = [[TestVibratoInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"21d2457647a5ac14a299f90524a09604");
}

@end

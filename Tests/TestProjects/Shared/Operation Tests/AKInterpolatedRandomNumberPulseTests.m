//
//  AKInterpolatedRandomNumberPulseTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestInterpolatedRandomNumberPulseInstrument : AKInstrument
@end

@implementation TestInterpolatedRandomNumberPulseInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKInterpolatedRandomNumberPulse *pulse = [AKInterpolatedRandomNumberPulse pulse];
        pulse.frequency = akp(3);

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = [pulse scaledBy:akp(4000)];

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKInterpolatedRandomNumberPulseTests : AKTestCase
@end

@implementation AKInterpolatedRandomNumberPulseTests

- (void)testInterpolatedRandomNumberPulse
{
    // Set up performance
    TestInterpolatedRandomNumberPulseInstrument *testInstrument = [[TestInterpolatedRandomNumberPulseInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"InterpolatedRandomNumberPulse"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSArray *validMD5s = @[@"996dd813043fd0556224cde3bb224085",
                           @"d31b2d360f352cb9c22e2c1ee006a76a"];
    XCTAssertTrue([validMD5s containsObject:[self md5ForFile:outputFile]]);
}

@end

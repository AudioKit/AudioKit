//
//  AKFMOscillatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestFMOscillatorInstrument : AKInstrument
@end

@implementation TestFMOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKLine *frequencyLine = [[AKLine alloc] initWithFirstPoint:akp(10)
                                                       secondPoint:akp(880)
                                             durationBetweenPoints:akp(testDuration)];
        AKLine *carrierMultiplierLine = [[AKLine alloc] initWithFirstPoint:akp(2)
                                                               secondPoint:akp(0)
                                                     durationBetweenPoints:akp(testDuration)];
        AKLine *modulatingMultiplierLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                                  secondPoint:akp(2)
                                                        durationBetweenPoints:akp(testDuration)];
        AKLine *indexLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(30)
                                         durationBetweenPoints:akp(testDuration)];
        // Instrument Definition
        AKFMOscillator *oscillator = [AKFMOscillator oscillator];
        oscillator.baseFrequency = frequencyLine;
        oscillator.carrierMultiplier = carrierMultiplierLine;
        oscillator.modulatingMultiplier = modulatingMultiplierLine;
        oscillator.modulationIndex = indexLine;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKFMOscillatorTests : AKTestCase
@end

@implementation AKFMOscillatorTests

- (void)testFMOscillator
{
    // Set up performance
    TestFMOscillatorInstrument *testInstrument = [[TestFMOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"dfe4b8c87584f8847acc1352ba3b2bf2");
}

- (void)testPresetBuzzer
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFMOscillator presetBuzzer]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0], @"850cd857039adb870a83573a972ecd08");
}

- (void)testPresetFoghorn
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFMOscillator presetFogHorn]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0], @"214908a4ee92b0696692e6e841c916f6");
}

- (void)testPresetSpaceWobble
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFMOscillator presetSpaceWobble]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0], @"ff899014015ea961fa208d42cb0875e6");
}

- (void)testPresetSpiral
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFMOscillator presetSpiral]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0], @"0ae1436fd2f47c2ad487ef9bdfa55c26");
}

- (void)testPresetStunRay
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFMOscillator presetStunRay]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0], @"8386b8c1e289c702846b97cc9eccc641");
}

- (void)testPresetWobble
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFMOscillator presetWobble]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0], @"79b9806fbea0d735ee8ea95a8d875737");
}

@end

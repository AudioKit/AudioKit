//
//  AKVCOscillatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestVCOscillatorInstrument : AKInstrument
@end

@interface TestVCOscillatorNote : AKNote
@property AKNoteProperty *waveformType;
- (instancetype)initWithWaveformType:(AKConstant *)waveformType;
@end

@implementation TestVCOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestVCOscillatorNote *note = [[TestVCOscillatorNote alloc] init];

        AKLine *frequencyLine = [[AKLine alloc] initWithFirstPoint:akp(110)
                                                       secondPoint:akp(880)
                                             durationBetweenPoints:akp(testDuration)];
        AKLine *pulseWidthLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                        secondPoint:akp(1)
                                              durationBetweenPoints:akp(testDuration)];
        // Instrument Definition
        AKVCOscillator *oscillator = [AKVCOscillator oscillator];
        oscillator.frequency = frequencyLine;
        oscillator.pulseWidth = pulseWidthLine;
        oscillator.waveformType = note.waveformType;

        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@implementation TestVCOscillatorNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _waveformType = [[AKNoteProperty alloc] init];
        [self addProperty:_waveformType];
    }
    return self;
}

- (instancetype)initWithWaveformType:(AKConstant *)waveformType
{
    self = [self init];
    if (self) {
        _waveformType.value = waveformType.value;
    }
    return self;
}
@end

@interface AKVCOscillatorTests : AKTestCase
@end

@implementation AKVCOscillatorTests {
    TestVCOscillatorInstrument *testInstrument;
}

- (void)setUp
{
    [super setUp];
    testInstrument = [[TestVCOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
}

- (void)testVCOscillatorSquareWave
{
    TestVCOscillatorNote *note = [[TestVCOscillatorNote alloc] initWithWaveformType:[AKVCOscillator waveformTypeForSquare]];
    note.duration.value = testDuration;
    [testInstrument playNote:note];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"115d39e4f38e60bfdcd7acc4fb000689");
}

- (void)testVCOscillatorSquareWithPWMWave
{
    TestVCOscillatorNote *note = [[TestVCOscillatorNote alloc] initWithWaveformType:[AKVCOscillator waveformTypeForSquareWithPWM]];
    note.duration.value = testDuration;
    [testInstrument playNote:note];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"bad62b3915e312087e4c4400bbe33933");
}

- (void)testVCOscillatorTriangleWave
{
    TestVCOscillatorNote *note = [[TestVCOscillatorNote alloc] initWithWaveformType:[AKVCOscillator waveformTypeForTriangle]];
    note.duration.value = testDuration;
    [testInstrument playNote:note];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"9951d11c22c131086963efd0205f9160");
}

- (void)testVCOscillatorSawtoothWave
{
    TestVCOscillatorNote *note = [[TestVCOscillatorNote alloc] initWithWaveformType:[AKVCOscillator waveformTypeForSawtooth]];
    note.duration.value = testDuration;
    [testInstrument playNote:note];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"24a97b1b156cb180a37904f2859a4fb3");
}

@end

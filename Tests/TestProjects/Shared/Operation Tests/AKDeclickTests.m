//
//  AKDeclickTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDeclickInstrument : AKInstrument
@end

@interface TestDeclickNote : AKNote
@property AKNoteProperty *declickedAmount;
- (instancetype)initWithDeclickedAmount:(float)declickedAmount;
@end

@implementation TestDeclickInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestDeclickNote *note = [[TestDeclickNote alloc] init];

        AKOscillator *sine = [AKOscillator oscillator];
        sine.amplitude = akp(0.5);
        AKDeclick *declickedSine = [[AKDeclick alloc] initWithInput:sine];
        AKMix *mix = [[AKMix alloc] initWithInput1:sine input2:declickedSine balance:note.declickedAmount];

        [self setAudioOutput:mix];
    }
    return self;
}

@end


@implementation TestDeclickNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _declickedAmount = [self createPropertyWithValue:0 minimum:0 maximum:1];
    }
    return self;
}

- (instancetype)initWithDeclickedAmount:(float)declickedAmount
{
    self = [self init];
    if (self) {
        _declickedAmount.value = (float)declickedAmount;
    }
    return self;
}
@end

@interface AKDeclickTests : AKTestCase
@end

@implementation AKDeclickTests

- (void)testDeclick
{
    // Set up performance
    TestDeclickInstrument *testInstrument = [[TestDeclickInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 20; i++) {
        TestDeclickNote *note = [[TestDeclickNote alloc] initWithDeclickedAmount:(float)i/20.0];
        note.duration.value = 0.25;
        [phrase addNote:note atTime:(float)i*0.5];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"6cb0438294cd6411c554662f17559885");
}

@end

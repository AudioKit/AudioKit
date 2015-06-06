//
//  AKStickTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestStickInstrument : AKInstrument
@end

@interface TestStickNote : AKNote
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
- (instancetype)initWithIntensity:(int)intensity dampingFactor:(float)dampingFactor;
@end

@implementation TestStickInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestStickNote *note = [[TestStickNote alloc] init];
        AKStick *stick = [AKStick stick];
        stick.intensity = note.intensity;
        stick.dampingFactor = note.dampingFactor;
        [self setAudioOutput:stick];
    }
    return self;
}

@end

@implementation TestStickNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity = [self createPropertyWithValue:1 minimum:0 maximum:1000];
        _dampingFactor = [self createPropertyWithValue:0 minimum:0 maximum:1];
    }
    return self;
}

- (instancetype)initWithIntensity:(int)intensity dampingFactor:(float)dampingFactor
{
    self = [self init];
    if (self) {
        _intensity.value = (float)intensity;
        _dampingFactor.value = dampingFactor;
    }
    return self;
}
@end


@interface AKStickTests : AKTestCase
@end

@implementation AKStickTests

- (void)testStick
{
    // Set up performance
    TestStickInstrument *testInstrument = [[TestStickInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 10; i++) {
        TestStickNote *note = [[TestStickNote alloc] initWithIntensity:(i+1)*20 dampingFactor:1.0-((float)i/20.0)];
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"4b37d5f659f0c7df24942efa3f4aa2a2");
}

- (void)testPresetBundleOfSticks
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKStick presetBundleOfSticks]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"91f413c1543d2b5dbac5b2e96c993608");
}

- (void)testPresetThickStick
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKStick presetThickStick]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"e69b33af7cd8fd880ce842ca9bde41b6");
}

@end

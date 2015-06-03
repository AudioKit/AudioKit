//
//  AKCrunchTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestCrunchInstrument : AKInstrument
@end

@interface TestCrunchNote : AKNote
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
- (instancetype)initWithIntensity:(int)intensity dampingFactor:(float)dampingFactor;
@end

@implementation TestCrunchInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestCrunchNote *note = [[TestCrunchNote alloc] init];
        AKCrunch *crunch = [AKCrunch crunch];
        crunch.intensity = note.intensity;
        crunch.dampingFactor = note.dampingFactor;
        [self setAudioOutput:crunch];
    }
    return self;
}

@end

@implementation TestCrunchNote

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


@interface AKCrunchTests : AKTestCase
@end

@implementation AKCrunchTests

- (void)testCrunch
{
    // Set up performance
    TestCrunchInstrument *testInstrument = [[TestCrunchInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 10; i++) {
        TestCrunchNote *note = [[TestCrunchNote alloc] initWithIntensity:40+(i+1)*20 dampingFactor:1.0-((float)i/10)];
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"6c1e307df84b104c94a7fdc221639d01");
}

@end

//
//  AKSleighbellsTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 5.0

@interface TestSleighbellsInstrument : AKInstrument
@end

@interface TestSleighbellsNote : AKNote
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *mainResonantFrequency;
@property AKNoteProperty *firstResonantFrequency;
@property AKNoteProperty *secondResonantFrequency;
@end

@implementation TestSleighbellsInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestSleighbellsNote *note = [[TestSleighbellsNote alloc] init];
        AKSleighbells *sleighbells = [AKSleighbells sleighbells];
        sleighbells.intensity = note.intensity;
        sleighbells.dampingFactor = note.dampingFactor;
        sleighbells.mainResonantFrequency = note.mainResonantFrequency;
        sleighbells.firstResonantFrequency = note.firstResonantFrequency;
        sleighbells.secondResonantFrequency = note.secondResonantFrequency;
        [self setAudioOutput:sleighbells];
    }
    return self;
}

@end

@implementation TestSleighbellsNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity               = [self createPropertyWithValue:32   minimum:0 maximum:1000];
        _dampingFactor           = [self createPropertyWithValue:0.2  minimum:0 maximum:1];
        _mainResonantFrequency   = [self createPropertyWithValue:2500 minimum:0 maximum:20000];
        _firstResonantFrequency  = [self createPropertyWithValue:5300 minimum:0 maximum:20000];
        _secondResonantFrequency = [self createPropertyWithValue:6500 minimum:0 maximum:20000];
    }
    return self;
}

@end


@interface AKSleighbellsTests : AKTestCase
@end

@implementation AKSleighbellsTests

- (void)testSleighbells
{
    // Set up performance
    TestSleighbellsInstrument *testInstrument = [[TestSleighbellsInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    TestSleighbellsNote *note = [[TestSleighbellsNote alloc] init];

    [phrase addNote:note atTime:1.0];
    [phrase addNote:note atTime:1.25];
    [phrase addNote:note atTime:1.5];
    [phrase addNote:note atTime:2.0];
    [phrase addNote:note atTime:2.25];
    [phrase addNote:note atTime:2.5];
    [phrase addNote:note atTime:3.0];
    [phrase addNote:note atTime:3.25];
    [phrase addNote:note atTime:3.5];
    [phrase addNote:note atTime:3.875];
    [phrase addNote:note atTime:4.0];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"5d3e31608ec30f414ee7bea3706daf83");
}


- (void)testPresetOpenBells
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKSleighbells presetOpenBells]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"ef73a9961f7c0d625e6b954d2e2da57e");
}

- (void)testPresetSoftBells
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKSleighbells presetSoftBells]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"ec5e5c68cb38f4eb47b701d98495ab03");
}

@end

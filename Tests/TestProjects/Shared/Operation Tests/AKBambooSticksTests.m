//
//  AKBambooSticksTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestBambooSticksInstrument : AKInstrument
@end

@interface TestBambooSticksNote : AKNote
@property AKNoteProperty *count;
@property AKNoteProperty *mainResonantFrequency;
- (instancetype)initWithCount:(int)count mainResonantFrequency:(float)mainResonantFrequency;
@end

@implementation TestBambooSticksInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestBambooSticksNote *note = [[TestBambooSticksNote alloc] init];
        AKBambooSticks *bambooSticks = [AKBambooSticks sticks];
        bambooSticks.count = note.count;
        bambooSticks.mainResonantFrequency = note.mainResonantFrequency;
        [self setAudioOutput:bambooSticks];
    }
    return self;
}

@end

@implementation TestBambooSticksNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = [self createPropertyWithValue:1 minimum:0 maximum:1000];
        _mainResonantFrequency = [self createPropertyWithValue:0 minimum:0 maximum:10000];
    }
    return self;
}

- (instancetype)initWithCount:(int)count mainResonantFrequency:(float)mainResonantFrequency
{
    self = [self init];
    if (self) {
        _count.value = (float)count;
        _mainResonantFrequency.value = mainResonantFrequency;
    }
    return self;
}
@end


@interface AKBambooSticksTests : AKTestCase
@end

@implementation AKBambooSticksTests

- (void)testBambooSticks
{
    // Set up performance
    TestBambooSticksInstrument *testInstrument = [[TestBambooSticksInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 10; i++) {
        TestBambooSticksNote *note = [[TestBambooSticksNote alloc] initWithCount:i mainResonantFrequency:1000+(float)i*300];
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"41575c04ef0a34949edaed7f411d12d8");
}

@end

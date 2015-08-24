//
//  AKCabasaTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestCabasaInstrument : AKInstrument
@end

@interface TestCabasaNote : AKNote
@property AKNoteProperty *count;
@property AKNoteProperty *dampingFactor;
- (instancetype)initWithCount:(int)count dampingFactor:(float)dampingFactor;
@end

@implementation TestCabasaInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestCabasaNote *note = [[TestCabasaNote alloc] init];
        AKCabasa *cabasa = [AKCabasa cabasa];
        cabasa.count = note.count;
        cabasa.dampingFactor = note.dampingFactor;
        [self setAudioOutput:cabasa];
    }
    return self;
}

@end

@implementation TestCabasaNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = [self createPropertyWithValue:1 minimum:0 maximum:1000];
        _dampingFactor = [self createPropertyWithValue:0 minimum:0 maximum:1];
    }
    return self;
}

- (instancetype)initWithCount:(int)count dampingFactor:(float)dampingFactor
{
    self = [self init];
    if (self) {
        _count.value = (float)count;
        _dampingFactor.value = dampingFactor;
    }
    return self;
}
@end


@interface AKCabasaTests : AKTestCase
@end

@implementation AKCabasaTests

- (void)testCabasa
{
    // Set up performance
    TestCabasaInstrument *testInstrument = [[TestCabasaInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 10; i++) {
        TestCabasaNote *note = [[TestCabasaNote alloc] initWithCount:(i+1)*20 dampingFactor:1.0-((float)i/10)];
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"feafff765315aeaf7cfa861df5c8cf47");
}

- (void)testPresetLooseCabasa
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKCabasa presetLooseCabasa]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"96a4c36f104920bfb6aec7578dbebb6f");
}

- (void)testPresetMutedCabasa
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKCabasa presetMutedCabasa]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"760ab27744552b0989ef884425842d6e");
}

@end

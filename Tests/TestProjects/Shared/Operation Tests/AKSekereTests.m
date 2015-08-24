//
//  AKSekereTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestSekereInstrument : AKInstrument
@end

@interface TestSekereNote : AKNote
@property AKNoteProperty *count;
@property AKNoteProperty *dampingFactor;
- (instancetype)initWithCount:(int)count dampingFactor:(float)dampingFactor;
@end

@implementation TestSekereInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestSekereNote *note = [[TestSekereNote alloc] init];
        AKSekere *sekere = [AKSekere sekere];
        sekere.count = note.count;
        sekere.dampingFactor = note.dampingFactor;
        [self setAudioOutput:sekere];
    }
    return self;
}

@end

@implementation TestSekereNote

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


@interface AKSekereTests : AKTestCase
@end

@implementation AKSekereTests

- (void)testSekere
{
    // Set up performance
    TestSekereInstrument *testInstrument = [[TestSekereInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 10; i++) {
        TestSekereNote *note = [[TestSekereNote alloc] initWithCount:(i+1)*20 dampingFactor:1.0-((float)i/10)];
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"5a67652835046d6f311e402baaf2ac66");
}

- (void)testPresetManyBeadsSekere
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKSekere presetManyBeadsSekere]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"6a310d10c9401085790da77ca9131cc2");
}


@end

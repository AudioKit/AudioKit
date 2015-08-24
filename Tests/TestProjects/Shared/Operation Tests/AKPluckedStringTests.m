//
//  AKPluckedStringTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 4.0

@interface TestPluckedStringInstrument : AKInstrument
@end

@interface TestPluckedStringNote : AKNote
@property AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;
@end

@implementation TestPluckedStringInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestPluckedStringNote *note = [[TestPluckedStringNote alloc] init];

        AKPluckedString *pluckedString = [AKPluckedString pluck];
        pluckedString.frequency = note.frequency;
        [self setAudioOutput:pluckedString];
    }
    return self;
}

@end

@implementation TestPluckedStringNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [self createPropertyWithValue:220 minimum:110 maximum:880];
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency
{
    self = [self init];
    if (self) {
        _frequency.value = frequency;
    }
    return self;
}
@end


@interface AKPluckedStringTests : AKTestCase
@end

@implementation AKPluckedStringTests

- (void)testPluckedString
{
    // Set up performance
    TestPluckedStringInstrument *testInstrument = [[TestPluckedStringInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    TestPluckedStringNote *note1 = [[TestPluckedStringNote alloc] initWithFrequency:440];
    TestPluckedStringNote *note2 = [[TestPluckedStringNote alloc] initWithFrequency:550];
    TestPluckedStringNote *note3 = [[TestPluckedStringNote alloc] initWithFrequency:660];
    note1.duration.value = note2.duration.value = note3.duration.value = 0.5;

    AKPhrase *phrase = [AKPhrase phrase];
    [phrase addNote:note1 atTime:0.5];
    [phrase addNote:note2 atTime:1.0];
    [phrase addNote:note3 atTime:1.5];
    [phrase addNote:note2 atTime:2.0];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"6a8f5e39c2076a4fc15856d099d3177a");
}

- (void)testPresetDecayingPluckedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKPluckedString presetDecayingPluckedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"7c3542668d2b53657d92ebf30aabdc59");
}

- (void)testPresetRoundedPluckedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKPluckedString presetRoundedPluckedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"acf4819edeb88c53d617ed7ed58ad2b7");
}

- (void)testPresetSnappyPluckedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKPluckedString presetSnappyPluckedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"e09ed1cb2e77e80b9da3cd884c80e4a6");
}

@end

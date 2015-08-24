//
//  AKMandolinTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 4.0

@interface TestMandolinInstrument : AKInstrument
@end

@interface TestMandolinNote : AKNote
@property AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;
@end

@implementation TestMandolinInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestMandolinNote *note = [[TestMandolinNote alloc] init];

        AKMandolin *mandolin = [AKMandolin mandolin];
        mandolin.frequency = note.frequency;
        [self setAudioOutput:mandolin];
    }
    return self;
}

@end

@implementation TestMandolinNote

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


@interface AKMandolinTests : AKTestCase
@end

@implementation AKMandolinTests

- (void)testMandolin
{
    // Set up performance
    TestMandolinInstrument *testInstrument = [[TestMandolinInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    TestMandolinNote *note1 = [[TestMandolinNote alloc] initWithFrequency:440];
    TestMandolinNote *note2 = [[TestMandolinNote alloc] initWithFrequency:550];
    TestMandolinNote *note3 = [[TestMandolinNote alloc] initWithFrequency:660];
    note1.duration.value = note2.duration.value = note3.duration.value = 0.5;

    AKPhrase *phrase = [AKPhrase phrase];
    [phrase addNote:note1 atTime:0.5];
    [phrase addNote:note2 atTime:1.0];
    [phrase addNote:note3 atTime:1.5];
    [phrase addNote:note2 atTime:2.0];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration],
                          @"b4f6c012da3abad0fc8a9263f5b6fe0b");
}

- (void)testPresetSmallMandolin
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKMandolin presetSmallMandolin]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"0c2f8f32cced40f23ffc83f837afaf5e");
    
}

- (void)testPresetDetunedMandolin
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKMandolin presetDetunedMandolin]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"8afcead9ee4bfc3cf8057593dc35b422");
    
}

@end

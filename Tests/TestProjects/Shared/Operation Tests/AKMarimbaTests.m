//
//  AKMarimbaTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 4.0

@interface TestMarimbaInstrument : AKInstrument
@end

@interface TestMarimbaNote : AKNote
@property AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;
@end

@implementation TestMarimbaInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestMarimbaNote *note = [[TestMarimbaNote alloc] init];

        AKMarimba *marimba = [AKMarimba marimba];
        marimba.frequency = note.frequency;
        [self setAudioOutput:marimba];
    }
    return self;
}

@end

@implementation TestMarimbaNote

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


@interface AKMarimbaTests : AKTestCase
@end

@implementation AKMarimbaTests

- (void)testMarimba
{
    // Set up performance
    TestMarimbaInstrument *testInstrument = [[TestMarimbaInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    TestMarimbaNote *note1 = [[TestMarimbaNote alloc] initWithFrequency:440];
    TestMarimbaNote *note2 = [[TestMarimbaNote alloc] initWithFrequency:550];
    TestMarimbaNote *note3 = [[TestMarimbaNote alloc] initWithFrequency:660];
    note1.duration.value = note2.duration.value = note3.duration.value = 0.5;

    AKPhrase *phrase = [AKPhrase phrase];
    [phrase addNote:note1 atTime:0.5];
    [phrase addNote:note2 atTime:1.0];
    [phrase addNote:note3 atTime:1.5];
    [phrase addNote:note2 atTime:2.0];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration],
                          @"f938d1376d60440ce271440ed3656177");
}

- (void)testPresetDryMutedMarimba
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKMarimba presetDryMutedMarimba]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"747a2f7c564cbb435a578fb2d270ed31");
    
}

- (void)testPresetDryGentleMarimba
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKMarimba presetGentleMarimba]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"fb0f853457aaddc5c27488dfddea5c04");
    
}

- (void)testPresetLooseMarimba
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKMarimba presetLooseMarimba]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"b19a7204fadac1f886c00982d29b554c");
    
}

@end

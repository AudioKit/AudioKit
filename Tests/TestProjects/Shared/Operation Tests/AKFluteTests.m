//
//  AKFluteTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 4.0

@interface TestFluteInstrument : AKInstrument
@end

@interface TestFluteNote : AKNote
@property AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;
@end

@implementation TestFluteInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestFluteNote *note = [[TestFluteNote alloc] init];

        AKFlute *flute = [AKFlute flute];
        flute.frequency = note.frequency;
        [self setAudioOutput:flute];
    }
    return self;
}

@end

@implementation TestFluteNote

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


@interface AKFluteTests : AKTestCase
@end

@implementation AKFluteTests

- (void)testFlute
{
    // Set up performance
    TestFluteInstrument *testInstrument = [[TestFluteInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    TestFluteNote *note1 = [[TestFluteNote alloc] initWithFrequency:440];
    TestFluteNote *note2 = [[TestFluteNote alloc] initWithFrequency:550];
    TestFluteNote *note3 = [[TestFluteNote alloc] initWithFrequency:660];
    note1.duration.value = note2.duration.value = note3.duration.value = 0.5;

    AKPhrase *phrase = [AKPhrase phrase];
    [phrase addNote:note1 atTime:0.5];
    [phrase addNote:note2 atTime:1.0];
    [phrase addNote:note3 atTime:1.5];
    [phrase addNote:note2 atTime:2.0];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"8690fb9e162012ed603adcf6d7ecaef4");
}


- (void)testPresetMicFeedbackFlute
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFlute presetMicFeedbackFlute]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"24dce15b7241d1c8d2dea0d72c10a51c");
}

- (void)testPresetSciFiNoiseFlute
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFlute presetSciFiNoiseFlute]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"f9af8a9e109b9e746a36c6def5857bcb");
}

- (void)testPresetScreamingFlute
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFlute presetScreamingFlute]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"df2d949f7929e01e2703ee358f338c6f");
}

- (void)testPresetShipsHornFlute
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKFlute presetShipsHornFlute]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"fb8609ec17dde8fdc99d8ba1b9da270f");
}

@end

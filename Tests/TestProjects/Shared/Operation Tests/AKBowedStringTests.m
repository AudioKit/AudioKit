//
//  AKBowedStringTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 4.0

@interface TestBowedStringInstrument : AKInstrument
@end

@interface TestBowedStringNote : AKNote
@property AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;
@end

@implementation TestBowedStringInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestBowedStringNote *note = [[TestBowedStringNote alloc] init];

        AKLinearEnvelope *envelope = [[AKLinearEnvelope alloc] initWithRiseTime:akp(0.2)
                                                                      decayTime:akp(0.2)
                                                                  totalDuration:akp(0.5)
                                                                      amplitude:akp(0.25)];
        AKBowedString *bowedString = [AKBowedString bowedString];
        bowedString.frequency = note.frequency;
        bowedString.vibratoFrequency = akp(4);
        bowedString.vibratoAmplitude = akp(0.01);
        bowedString.amplitude = envelope;
        [self setAudioOutput:bowedString];
    }
    return self;
}

@end

@implementation TestBowedStringNote

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


@interface AKBowedStringTests : AKTestCase
@end

@implementation AKBowedStringTests

- (void)testBowedString
{
    // Set up performance
    TestBowedStringInstrument *testInstrument = [[TestBowedStringInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    TestBowedStringNote *note1 = [[TestBowedStringNote alloc] initWithFrequency:440];
    TestBowedStringNote *note2 = [[TestBowedStringNote alloc] initWithFrequency:550];
    TestBowedStringNote *note3 = [[TestBowedStringNote alloc] initWithFrequency:660];
    note1.duration.value = note2.duration.value = note3.duration.value = 0.5;

    AKPhrase *phrase = [AKPhrase phrase];
    [phrase addNote:note1 atTime:0.5];
    [phrase addNote:note2 atTime:1.0];
    [phrase addNote:note3 atTime:1.5];
    [phrase addNote:note2 atTime:2.0];

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"22cc703d0282180934d7ca084815eb0a");
}

- (void)testPresetCelloBowedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKBowedString presetCelloBowedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"0628ab36a96bccc312163cd807576dfa");
}

- (void)testPresetFeedbackBowedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKBowedString presetFeedbackBowedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"25c0b3bab9e1a92bed6d2597fc2a9671");
}

- (void)testPresetFogHornBowedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKBowedString presetFogHornBowedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"d2f55a33b3a43ad31b15f73aa9c71ff0");
}

- (void)testPresetTrainWhistleBowedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKBowedString presetTrainWhislteBowedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"a2704c34dcbb8b18412c91402e54704c");
}

- (void)testPresetWhistlingBowedString
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKBowedString presetWhistlingBowedString]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"03cf6dece4a2192eec1dd3f6d381fd6a");
}

@end

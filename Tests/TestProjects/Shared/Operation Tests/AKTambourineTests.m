//
//  AKTambourineTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestTambourineInstrument : AKInstrument
@end

@interface TestTambourineNote : AKNote
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
@property AKNoteProperty *mainResonantFrequency;
- (instancetype)initWithIntensity:(int)intensity
                    dampingFactor:(float)dampingFactor
            mainResonantFrequency:(float)mainResonantFrequency;
@end

@implementation TestTambourineInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestTambourineNote *note = [[TestTambourineNote alloc] init];
        AKTambourine *tambourine = [AKTambourine tambourine];
        tambourine.intensity = note.intensity;
        tambourine.dampingFactor = note.dampingFactor;
        tambourine.mainResonantFrequency = note.mainResonantFrequency;
        [self setAudioOutput:tambourine];
    }
    return self;
}

@end

@implementation TestTambourineNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity = [self createPropertyWithValue:1 minimum:0 maximum:1000];
        _dampingFactor = [self createPropertyWithValue:0 minimum:0 maximum:1];
        _mainResonantFrequency = [self createPropertyWithValue:0 minimum:0 maximum:20000];
    }
    return self;
}

- (instancetype)initWithIntensity:(int)intensity
                    dampingFactor:(float)dampingFactor
            mainResonantFrequency:(float)mainResonantFrequency
{
    self = [self init];
    if (self) {
        _intensity.value = (float)intensity;
        _dampingFactor.value = dampingFactor;
        _mainResonantFrequency.value = mainResonantFrequency;
    }
    return self;
}
@end


@interface AKTambourineTests : AKTestCase
@end

@implementation AKTambourineTests

- (void)testTambourine
{
    // Set up performance
    TestTambourineInstrument *testInstrument = [[TestTambourineInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 20; i++) {
        TestTambourineNote *note = [[TestTambourineNote alloc] initWithIntensity:25+(i+1)*20
                                                                   dampingFactor:1.0-((float)i/20)
                                                           mainResonantFrequency:200*(float)i];
        note.duration.value = 0.5;
        [phrase addNote:note atTime:(float)i*0.5];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"8c88f6eb00209fc63946052854d5f09c");
}

- (void)testPresetClosedTambourine
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKTambourine presetClosedTambourine]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"82e5675e159055f279d71692569c5267");
}

- (void)testPresetOpenTambourine
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKTambourine presetOpenTambourine]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"1fa2680fb57c3757a64f4ec8ab140201");
}

@end

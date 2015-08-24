//
//  AKVibesTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 4.0

@interface TestVibesInstrument : AKInstrument
@end

@interface TestVibesNote : AKNote
@property AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;
@end

@implementation TestVibesInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestVibesNote *note = [[TestVibesNote alloc] init];
        AKVibes *vibes = [AKVibes vibes];
        vibes.frequency = note.frequency;
        [self setAudioOutput:vibes];
    }
    return self;
}

@end

@implementation TestVibesNote

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


@interface AKVibesTests : AKTestCase
@end

@implementation AKVibesTests

- (void)testVibes
{
    // Set up performance
    TestVibesInstrument *testInstrument = [[TestVibesInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    TestVibesNote *note1 = [[TestVibesNote alloc] initWithFrequency:440];
    TestVibesNote *note2 = [[TestVibesNote alloc] initWithFrequency:550];
    TestVibesNote *note3 = [[TestVibesNote alloc] initWithFrequency:660];

    AKPhrase *phrase = [AKPhrase phrase];
    [phrase addNote:note1 atTime:0.5];
    [phrase addNote:note2 atTime:1.0];
    [phrase addNote:note3 atTime:1.5];
    [phrase addNote:note2 atTime:2.0];

    // Removing the playphrase for now
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"e7bb11845629d642982b47868a63b6b8");
}

- (void)testPresetGentleVibes
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKVibes presetGentleVibes]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"a4f079a3a5b1fc4b3769449e095a57ee");
}

- (void)testPresetRingingVibes
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKVibes presetRingingVibes]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"e27b0260922d306fb6ca99f79731e9a5");
}

- (void)testPresetTinyVibes
{
    AKInstrument *testInstrument = [AKInstrument instrument];
    [testInstrument setAudioOutput:[AKVibes presetTinyVibes]];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    XCTAssertEqualObjects([self md5ForOutputWithDuration:1.0],
                          @"e1cdcdbd0750419a6984e04a98656ade");
}

@end

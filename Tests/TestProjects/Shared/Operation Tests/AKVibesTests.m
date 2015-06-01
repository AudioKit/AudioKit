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

    [testInstrument playPhrase:phrase];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"Vibes"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"6d150cc0fec80b45b96754229edb7e6c");
}

@end

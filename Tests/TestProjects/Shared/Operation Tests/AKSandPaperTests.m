//
//  AKSandPaperTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestSandPaperInstrument : AKInstrument
@end

@interface TestSandPaperNote : AKNote
@property AKNoteProperty *intensity;
@property AKNoteProperty *dampingFactor;
- (instancetype)initWithIntensity:(int)intensity dampingFactor:(float)dampingFactor;
@end

@implementation TestSandPaperInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestSandPaperNote *note = [[TestSandPaperNote alloc] init];
        AKSandPaper *sandPaper = [AKSandPaper sandPaper];
        sandPaper.intensity = note.intensity;
        sandPaper.dampingFactor = note.dampingFactor;
        [self setAudioOutput:sandPaper];
    }
    return self;
}

@end

@implementation TestSandPaperNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intensity = [self createPropertyWithValue:1 minimum:0 maximum:1000];
        _dampingFactor = [self createPropertyWithValue:0 minimum:0 maximum:1];
    }
    return self;
}

- (instancetype)initWithIntensity:(int)intensity dampingFactor:(float)dampingFactor
{
    self = [self init];
    if (self) {
        _intensity.value = (float)intensity;
        _dampingFactor.value = dampingFactor;
    }
    return self;
}
@end


@interface AKSandPaperTests : AKTestCase
@end

@implementation AKSandPaperTests

- (void)testSandPaper
{
    // Set up performance
    TestSandPaperInstrument *testInstrument = [[TestSandPaperInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 10; i++) {
        TestSandPaperNote *note = [[TestSandPaperNote alloc] initWithIntensity:40+(i+1)*20 dampingFactor:1.0-((float)i/10)];
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"SandPaper"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForFile:outputFile], @"3bb56ecfcda87114ba28b8c272fb1ecd");
}

@end

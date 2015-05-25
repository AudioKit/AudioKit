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
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Flute.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"8690fb9e162012ed603adcf6d7ecaef4");
}

@end

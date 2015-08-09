//
//  AKGuiroTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestGuiroInstrument : AKInstrument
@end

@interface TestGuiroNote : AKNote
@property AKNoteProperty *count;
@property AKNoteProperty *mainResonantFrequency;
- (instancetype)initWithCount:(int)count
        mainResonantFrequency:(float)mainResonantFrequency;
@end

@implementation TestGuiroInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        TestGuiroNote *note = [[TestGuiroNote alloc] init];
        AKGuiro *guiro = [AKGuiro guiro];
        guiro.count = note.count;
        guiro.mainResonantFrequency = note.mainResonantFrequency;
        [self setAudioOutput:guiro];
    }
    return self;
}

@end

@implementation TestGuiroNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _count = [self createPropertyWithValue:1 minimum:0 maximum:1000];
        _mainResonantFrequency = [self createPropertyWithValue:0 minimum:0 maximum:20000];
    }
    return self;
}

- (instancetype)initWithCount:(int)count
        mainResonantFrequency:(float)mainResonantFrequency
{
    self = [self init];
    if (self) {
        _count.value = (float)count;
        _mainResonantFrequency.value = mainResonantFrequency;
    }
    return self;
}
@end


@interface AKGuiroTests : AKTestCase
@end

@implementation AKGuiroTests

- (void)testGuiro
{
    // Set up performance
    TestGuiroInstrument *testInstrument = [[TestGuiroInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];

    AKPhrase *phrase = [AKPhrase phrase];

    for (int i = 0; i < 20; i++) {
        TestGuiroNote *note = [[TestGuiroNote alloc] initWithCount:(i+1)*20
                                             mainResonantFrequency:1500+500*(float)i];;
        note.duration.value = 1.0;
        [phrase addNote:note atTime:(float)i];
    }

    [testInstrument playPhrase:phrase];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"ea553375944b803848a07fee7d67819e");
}

@end

//
//  AKTableLooperTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestTableLooperInstrument : AKInstrument
@end

@implementation TestTableLooperInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"mandpluk" ofType:@"aif"];
        AKSoundFileTable *soundfile = [[AKSoundFileTable alloc] initWithFilename:filename];

        AKLine *speed = [[AKLine alloc] initWithFirstPoint:akp(3)
                                               secondPoint:akp(0.5)
                                     durationBetweenPoints:akp(testDuration)];

        AKTableLooper *looper = [[AKTableLooper alloc] initWithTable:soundfile];
        looper.endTime = akp(9.6);
        looper.transpositionRatio = speed;
        looper.loopMode = [AKStereoSoundFileLooper loopPlaysForwardAndThenBackwards];

        [self setAudioOutput:looper];
    }
    return self;
}

@end

@interface AKTableLooperTests : AKTestCase
@end

@implementation AKTableLooperTests

- (void)testTableLooper
{
    // Set up performance
    TestTableLooperInstrument *testInstrument = [[TestTableLooperInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"f88e0ebca4f64f61b6790ede110b8dc6");
}

@end

//
//  AKStereoSoundFileLooperTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestStereoSoundFileLooperInstrument : AKInstrument
@end

@implementation TestStereoSoundFileLooperInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKSoundFileTable *soundfile = [[AKSoundFileTable alloc] initWithFilename:filename];

        AKLine *speed = [[AKLine alloc] initWithFirstPoint:akp(4)
                                               secondPoint:akp(0.2)
                                     durationBetweenPoints:akp(testDuration)];

        AKStereoSoundFileLooper *looper = [[AKStereoSoundFileLooper alloc] initWithSoundFile:soundfile];
        looper.frequencyRatio = speed;
        looper.loopMode = [AKStereoSoundFileLooper loopPlaysForwardAndThenBackwards];

        [self setAudioOutput:looper];
    }
    return self;
}

@end

@interface AKStereoSoundFileLooperTests : AKTestCase
@end

@implementation AKStereoSoundFileLooperTests

- (void)testStereoSoundFileLooper
{
    // Set up performance
    TestStereoSoundFileLooperInstrument *testInstrument = [[TestStereoSoundFileLooperInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"e97059b3b9e7cdf24e7f3ca0a1d15bcf");
}

@end

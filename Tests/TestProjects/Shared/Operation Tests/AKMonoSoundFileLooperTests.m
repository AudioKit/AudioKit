//
//  AKMonoSoundFileLooperTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestMonoSoundFileLooperInstrument : AKInstrument
@end

@implementation TestMonoSoundFileLooperInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"mandpluk" ofType:@"aif"];
        AKSoundFileTable *soundfile = [[AKSoundFileTable alloc] initWithFilename:filename];

        AKLine *speed = [[AKLine alloc] initWithFirstPoint:akp(10)
                                               secondPoint:akp(0.2)
                                     durationBetweenPoints:akp(testDuration)];

        AKMonoSoundFileLooper *looper = [[AKMonoSoundFileLooper alloc] initWithSoundFile:soundfile];
        looper.frequencyRatio = speed;

        [self setAudioOutput:looper];
    }
    return self;
}

@end

@interface AKMonoSoundFileLooperTests : AKTestCase
@end

@implementation AKMonoSoundFileLooperTests

- (void)testMonoSoundFileLooper
{
    // Set up performance
    TestMonoSoundFileLooperInstrument *testInstrument = [[TestMonoSoundFileLooperInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"28c1d869c0512a946ed1054aaa14a82d");
}

@end

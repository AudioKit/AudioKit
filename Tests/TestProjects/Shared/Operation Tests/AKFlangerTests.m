//
//  AKFlangerTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestFlangerInstrument : AKInstrument
@end

@implementation TestFlangerInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *delayTime = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(0.1)
                                         durationBetweenPoints:akp(testDuration)];
        AKLine *feedback = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                  secondPoint:akp(1)
                                        durationBetweenPoints:akp(testDuration)];
        AKFlanger *flanger = [[AKFlanger alloc] initWithInput:mono delayTime:delayTime];
        flanger.feedback = feedback;

        AKMix *mix = [[AKMix alloc] initWithInput1:mono input2:flanger balance:akp(0.5)];

        [self setAudioOutput:mix];
    }
    return self;
}

@end

@interface AKFlangerTests : AKTestCase
@end

@implementation AKFlangerTests

- (void)testFlanger
{
    // Set up performance
    TestFlangerInstrument *testInstrument = [[TestFlangerInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"e0f40e2cc560c2decc6d3dbc86795df9");
}

@end

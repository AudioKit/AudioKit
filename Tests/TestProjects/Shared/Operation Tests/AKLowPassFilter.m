//
//  AKLowPassFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestLowPassFilterInstrument : AKInstrument
@end

@implementation TestLowPassFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *halfPowerPoint = [[AKLine alloc] initWithFirstPoint:akp(1000)
                                                        secondPoint:akp(0)
                                              durationBetweenPoints:akp(testDuration)];

        AKLowPassFilter *lowPassFilter = [[AKLowPassFilter alloc] initWithInput:mono];
        lowPassFilter.halfPowerPoint = halfPowerPoint;

        [self setAudioOutput:lowPassFilter];
    }
    return self;
}

@end

@interface AKLowPassFilterTests : AKTestCase
@end

@implementation AKLowPassFilterTests

- (void)testLowPassFilter
{
    // Set up performance
    TestLowPassFilterInstrument *testInstrument = [[TestLowPassFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"0c99def8c3e194deb1506ef4da32edbd");
}

- (void)testMuffledFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKLowPassFilter *presetFilter = [AKLowPassFilter presetMuffledFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"99aa0dc68889c03bb5586e1d9b531afc");
}

@end

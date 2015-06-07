//
//  AKThreePoleLowpassFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestThreePoleLowpassFilterInstrument : AKInstrument
@end

@implementation TestThreePoleLowpassFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKPhasor *phasor = [AKPhasor phasor];
        AKLine *distortion = [[AKLine alloc] initWithFirstPoint:akp(0.1)
                                                    secondPoint:akp(0.9)
                                          durationBetweenPoints:akp(testDuration)];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(300)
                                                         secondPoint:akp(3000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *resonance = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(1)
                                         durationBetweenPoints:akp(testDuration)];
        AKThreePoleLowpassFilter *threePoleLowpassFilter = [[AKThreePoleLowpassFilter alloc] initWithInput:phasor];
        threePoleLowpassFilter.distortion      = distortion;
        threePoleLowpassFilter.cutoffFrequency = cutoffFrequency;
        threePoleLowpassFilter.resonance       = resonance;

        [self setAudioOutput:threePoleLowpassFilter];
    }
    return self;
}

@end

@interface AKThreePoleLowpassFilterTests : AKTestCase
@end

@implementation AKThreePoleLowpassFilterTests

- (void)testThreePoleLowpassFilter
{
    // Set up performance
    TestThreePoleLowpassFilterInstrument *testInstrument = [[TestThreePoleLowpassFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"2bb808ae078e6adf296662cdb354654a");
}

- (void)testPresetBrightFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKThreePoleLowpassFilter *presetFilter = [AKThreePoleLowpassFilter presetBrightFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"c9a1561852fc6c67353ed3f162655307");
}

- (void)testPresetDullBassWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKThreePoleLowpassFilter *presetFilter = [AKThreePoleLowpassFilter presetDullBassWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"572fe6f544068c93f8cc4757498f77a0");
}

- (void)testPresetScreamWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKThreePoleLowpassFilter *presetFilter = [AKThreePoleLowpassFilter presetScreamWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"7f351499d3512d97308e758cf92a08ba");
}

@end

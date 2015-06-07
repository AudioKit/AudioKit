//
//  AKVariableFrequencyResponseBandPassFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestVariableFrequencyRepsonseBandPassFilterInstrument : AKInstrument
@end

@implementation TestVariableFrequencyRepsonseBandPassFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(220)
                                                         secondPoint:akp(3000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(10)
                                                   secondPoint:akp(100)
                                         durationBetweenPoints:akp(testDuration)];
        AKVariableFrequencyResponseBandPassFilter *variableFrequencyResponseBandPassFilter = [[AKVariableFrequencyResponseBandPassFilter alloc] initWithInput:mono];
        variableFrequencyResponseBandPassFilter.cutoffFrequency = cutoffFrequency;
        variableFrequencyResponseBandPassFilter.bandwidth = bandwidth;
        variableFrequencyResponseBandPassFilter.scalingFactor = [AKVariableFrequencyResponseBandPassFilter scalingFactorPeak];

        [self setAudioOutput:variableFrequencyResponseBandPassFilter];
    }
    return self;
}

@end

@interface AKVariableFrequencyResponseBandPassFilterTests : AKTestCase
@end

@implementation AKVariableFrequencyResponseBandPassFilterTests

- (void)testVariableFrequencyRepsonseBandPassFilter
{
    // Set up performance
    TestVariableFrequencyRepsonseBandPassFilterInstrument *testInstrument = [[TestVariableFrequencyRepsonseBandPassFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"26f0bc7ece1c2685d8a900b27facacad");
}

- (void)testPresetBassPeakFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKVariableFrequencyResponseBandPassFilter *presetFilter = [AKVariableFrequencyResponseBandPassFilter presetBassPeakFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"9135672ca5f2fbef0c09f5ebfb843045");
}

- (void)testPresetLargeMuffledFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKVariableFrequencyResponseBandPassFilter *presetFilter = [AKVariableFrequencyResponseBandPassFilter presetLargeMuffledFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"74f8f8975348b1c45feccfa0f3c2c679");
}

- (void)testPresetMuffledFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKVariableFrequencyResponseBandPassFilter *presetFilter = [AKVariableFrequencyResponseBandPassFilter presetMuffledFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"d033065c04f69e8b267d42fa99bfdb04");
}

- (void)testPresetTreblePeakFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKVariableFrequencyResponseBandPassFilter *presetFilter = [AKVariableFrequencyResponseBandPassFilter presetTreblePeakFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"11cae5e564672c1fd217474e23eb4e9b");
}

@end

//
//  AKDecimatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDecimatorInstrument : AKInstrument
@end

@implementation TestDecimatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *bitDepth = [[AKLine alloc] initWithFirstPoint:akp(24)
                                                  secondPoint:akp(18)
                                        durationBetweenPoints:akp(testDuration)];
        AKLine *sampleRate = [[AKLine alloc] initWithFirstPoint:akp(5000)
                                                    secondPoint:akp(1000)
                                          durationBetweenPoints:akp(testDuration)];
        AKDecimator *decimator = [[AKDecimator alloc] initWithInput:mono];
        decimator.bitDepth = bitDepth;
        decimator.sampleRate = sampleRate;

        [self setAudioOutput:decimator];
    }
    return self;
}

@end

@interface AKDecimatorTests : AKTestCase
@end

@implementation AKDecimatorTests

- (void)testDecimator
{
    // Set up performance
    TestDecimatorInstrument *testInstrument = [[TestDecimatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"a62dd414fe5ebb6e21b3099ce1287e7e");
}

- (void)testPresetCrunchyDecimatorWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDecimator *presetFilter = [AKDecimator presetCrunchyDecimatorWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"6be7493e2045016a4e3f9eb385b3a4f9");
}

- (void)testPresetRobotDecimatorWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDecimator *presetFilter = [AKDecimator presetRobotDecimatorWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"d82efeee48b79888303034abae081183");
}

- (void)testPresetVideogameDecimatorWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDecimator *presetFilter = [AKDecimator presetVideogameDecimatorWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"dca62ff43af1c3876704706f6006bffa");
}

@end

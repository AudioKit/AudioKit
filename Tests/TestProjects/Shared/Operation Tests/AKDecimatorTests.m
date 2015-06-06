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
    AKDecimator *presetReverb = [AKDecimator presetCrunchyDecimatorWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"6b12ff8c9cccbd976b10c9e0be9cda79");
}

- (void)testPresetRobotDecimatorWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDecimator *presetReverb = [AKDecimator presetRobotDecimatorWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"5cca821f1ed39179cff644910a18fc88");
}

- (void)testPresetVideogameDecimatorWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDecimator *presetReverb = [AKDecimator presetVideogameDecimatorWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"609ed9678fd132226bd8a6f489fe7e9d");
}

@end

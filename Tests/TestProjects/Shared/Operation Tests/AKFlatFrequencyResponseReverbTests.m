//
//  AKFlatFrequencyResponseReverbTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestFlatFrequencyResponseReverbInstrument : AKInstrument
@end

@implementation TestFlatFrequencyResponseReverbInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *reverbDuration = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                  secondPoint:akp(1)
                                        durationBetweenPoints:akp(testDuration)];
        AKFlatFrequencyResponseReverb *flatFrequencyResponseReverb = [[AKFlatFrequencyResponseReverb alloc] initWithInput:mono];
        flatFrequencyResponseReverb.reverbDuration = reverbDuration;

        [self setAudioOutput:flatFrequencyResponseReverb];
    }
    return self;
}

@end

@interface AKFlatFrequencyResponseReverbTests : AKTestCase
@end

@implementation AKFlatFrequencyResponseReverbTests

- (void)testFlatFrequencyResponseReverb
{
    // Set up performance
    TestFlatFrequencyResponseReverbInstrument *testInstrument = [[TestFlatFrequencyResponseReverbInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"bbbc6fe8afa513f8e799786e80509db1");
}

- (void)testPresetpresetMetallicReverbWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKFlatFrequencyResponseReverb *presetReverb = [AKFlatFrequencyResponseReverb presetMetallicReverbWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"b20c829d53b2170101ab3da654797fc5");
}

- (void)testPresetpresetStutteringReverbWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKFlatFrequencyResponseReverb *presetReverb = [AKFlatFrequencyResponseReverb presetStutteringReverbWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"da3529ade715a6053b59c9afb4b5ae19");
}


@end

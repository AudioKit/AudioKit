//
//  AKMoogVCFTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestMoogVCFInstrument : AKInstrument
@end

@implementation TestMoogVCFInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(2000)
                                                         secondPoint:akp(0)
                                               durationBetweenPoints:akp(testDuration)];

        AKMoogVCF *moogVCF = [[AKMoogVCF alloc] initWithInput:mono];
        moogVCF.cutoffFrequency = cutoffFrequency;

        [self setAudioOutput:moogVCF];
    }
    return self;
}

@end

@interface AKMoogVCFTests : AKTestCase
@end

@implementation AKMoogVCFTests

- (void)testMoogVCF
{
    // Set up performance
    TestMoogVCFInstrument *testInstrument = [[TestMoogVCFInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"5bc5b6b23038bff35bba2d5bff1fe7d1");
}

- (void)testPresetFoggyBottomFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKMoogVCF *presetFilter = [AKMoogVCF presetFoggyBottomFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"32d362dfa3ee2111917eebedd10ba53b");
}

- (void)testPresetHighTrebleFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKMoogVCF *presetFilter = [AKMoogVCF presetHighTrebleFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"a7196a9a7a9252dc447292e799a0fb4d");
}

@end

//
//  AKParallelCombLowPassFilterReverbTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestParallelCombLowPassFilterReverbInstrument : AKInstrument
@end

@implementation TestParallelCombLowPassFilterReverbInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *reverbTime = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                    secondPoint:akp(2)
                                          durationBetweenPoints:akp(testDuration)];
        AKLine *highFrequencyDiffusivity = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                                  secondPoint:akp(1)
                                                        durationBetweenPoints:akp(testDuration)];

        AKParallelCombLowPassFilterReverb *reverb = [[AKParallelCombLowPassFilterReverb alloc] initWithInput:mono];
        reverb.duration = reverbTime;
        reverb.highFrequencyDiffusivity = highFrequencyDiffusivity;

        [self setAudioOutput:reverb];
    }
    return self;
}

@end

@interface AKParallelCombLowPassFilterReverbTests : AKTestCase
@end

@implementation AKParallelCombLowPassFilterReverbTests

- (void)testParallelCombLowPassFilterReverb
{
    // Set up performance
    TestParallelCombLowPassFilterReverbInstrument *testInstrument = [[TestParallelCombLowPassFilterReverbInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"0d01938ebadf30b17460e8c0791424a2");
}

@end

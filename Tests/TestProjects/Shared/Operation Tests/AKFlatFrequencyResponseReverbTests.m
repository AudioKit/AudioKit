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

@end

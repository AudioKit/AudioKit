//
//  AKPeakingParametricEqualizerFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestPeakingParametricEqualizerFilterInstrument : AKInstrument
@end

@implementation TestPeakingParametricEqualizerFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(1000)
                                                         secondPoint:akp(2000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *resonance = [[AKLine alloc] initWithFirstPoint:akp(0.5)
                                                   secondPoint:akp(2)
                                         durationBetweenPoints:akp(testDuration)];
        AKLine *gain = [[AKLine alloc] initWithFirstPoint:akp(0)
                                              secondPoint:akp(2)
                                    durationBetweenPoints:akp(testDuration)];
        AKPeakingParametricEqualizerFilter *filter = [[AKPeakingParametricEqualizerFilter alloc] initWithInput:mono
                                                                                               centerFrequency:centerFrequency
                                                                                                     resonance:resonance
                                                                                                          gain:gain];

        [self setAudioOutput:filter];
    }
    return self;
}

@end

@interface AKPeakingParametricEqualizerFilterTests : AKTestCase
@end

@implementation AKPeakingParametricEqualizerFilterTests

- (void)testPeakingParametricEqualizerFilter
{
    // Set up performance
    TestPeakingParametricEqualizerFilterInstrument *testInstrument = [[TestPeakingParametricEqualizerFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"2c2f5dd304ddfa82e88a958e6fec8917");
}

@end

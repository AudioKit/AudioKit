//
//  AKHighShelfParametricEqualizerFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestHighShelfParametricEqualizerFilterInstrument : AKInstrument
@end

@implementation TestHighShelfParametricEqualizerFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *cornerFrequency = [[AKLine alloc] initWithFirstPoint:akp(1000)
                                                         secondPoint:akp(2000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *resonance = [[AKLine alloc] initWithFirstPoint:akp(0.5)
                                                   secondPoint:akp(2)
                                         durationBetweenPoints:akp(testDuration)];
        
        AKLine *gain = [[AKLine alloc] initWithFirstPoint:akp(0)
                                              secondPoint:akp(2)
                                    durationBetweenPoints:akp(testDuration)];
        AKHighShelfParametricEqualizerFilter *filter = [[AKHighShelfParametricEqualizerFilter alloc] initWithInput:mono
                                                                                                 cornerFrequency:cornerFrequency
                                                                                                       resonance:resonance
                                                                                                            gain:gain];
        
        [self setAudioOutput:filter];
    }
    return self;
}

@end

@interface AKHighShelfParametricEqualizerFilterTests : AKTestCase
@end

@implementation AKHighShelfParametricEqualizerFilterTests

- (void)testHighShelfParametricEqualizerFilter
{
    // Set up performance
    TestHighShelfParametricEqualizerFilterInstrument *testInstrument = [[TestHighShelfParametricEqualizerFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"1cbba4d574ffb3c6329b9e7d016e908b");
}

@end

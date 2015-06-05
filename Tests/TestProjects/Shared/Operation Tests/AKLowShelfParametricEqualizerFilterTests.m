//
//  AKLowShelfParametricEqualizerFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestLowShelfParametricEqualizerFilterInstrument : AKInstrument
@end

@implementation TestLowShelfParametricEqualizerFilterInstrument

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
        AKLowShelfParametricEqualizerFilter *filter = [[AKLowShelfParametricEqualizerFilter alloc] initWithInput:mono
                                                                                               cornerFrequency:cornerFrequency
                                                                                                     resonance:resonance
                                                                                                          gain:gain];
        
        [self setAudioOutput:filter];
    }
    return self;
}

@end

@interface AKLowShelfParametricEqualizerFilterTests : AKTestCase
@end

@implementation AKLowShelfParametricEqualizerFilterTests

- (void)testLowShelfParametricEqualizerFilter
{
    // Set up performance
    TestLowShelfParametricEqualizerFilterInstrument *testInstrument = [[TestLowShelfParametricEqualizerFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"0a02061fa7049a71d575c40439966eb0");
}

@end

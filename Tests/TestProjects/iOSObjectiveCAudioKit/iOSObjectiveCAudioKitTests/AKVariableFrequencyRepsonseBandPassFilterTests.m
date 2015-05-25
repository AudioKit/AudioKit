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
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-VariableFrequencyRepsonseBandPassFilter.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"26f0bc7ece1c2685d8a900b27facacad");
}

@end

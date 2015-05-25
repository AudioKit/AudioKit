//
//  AKHighPassFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestHighPassFilterInstrument : AKInstrument
@end

@implementation TestHighPassFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                         secondPoint:akp(4000)
                                               durationBetweenPoints:akp(testDuration)];
        
        AKHighPassFilter *highPassFilter = [[AKHighPassFilter alloc] initWithInput:mono];
        highPassFilter.cutoffFrequency = cutoffFrequency;
        
        [self setAudioOutput:highPassFilter];
    }
    return self;
}

@end

@interface AKHighPassFilterTests : AKTestCase
@end

@implementation AKHighPassFilterTests

- (void)testHighPassFilter
{
    // Set up performance
    TestHighPassFilterInstrument *testInstrument = [[TestHighPassFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-HighPassFilter.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"bf35ac2861e6ca595fca60d133c97a4d");
}

@end

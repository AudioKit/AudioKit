//
//  AKResonantFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestResonantFilterInstrument : AKInstrument
@end

@implementation TestResonantFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                         secondPoint:akp(5000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(500)
                                                   secondPoint:akp(0)
                                         durationBetweenPoints:akp(testDuration)];
        AKResonantFilter *ResonantFilter = [[AKResonantFilter alloc] initWithInput:mono];
        ResonantFilter.centerFrequency = centerFrequency;
        ResonantFilter.bandwidth       = bandwidth;

        [self setAudioOutput:ResonantFilter];
    }
    return self;
}

@end

@interface AKResonantFilterTests : AKTestCase
@end

@implementation AKResonantFilterTests

- (void)testResonantFilter
{
    // Set up performance
    TestResonantFilterInstrument *testInstrument = [[TestResonantFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"ResonantFilter"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"7f168a952d7c1272ce811986aa54ab4b");
}

@end

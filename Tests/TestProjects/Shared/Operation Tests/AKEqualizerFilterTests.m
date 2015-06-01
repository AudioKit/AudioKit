//
//  AKEqualizerFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestEqualizerFilterInstrument : AKInstrument
@end

@implementation TestEqualizerFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(200)
                                                         secondPoint:akp(2500)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                   secondPoint:akp(100)
                                         durationBetweenPoints:akp(testDuration)];
        AKEqualizerFilter *equalizerFilter = [[AKEqualizerFilter alloc] initWithInput:mono];
        equalizerFilter.centerFrequency = centerFrequency;
        equalizerFilter.bandwidth = bandwidth;
        equalizerFilter.gain = akp(100);

        [self setAudioOutput:[equalizerFilter scaledBy:akp(0.5)]];
    }
    return self;
}

@end

@interface AKEqualizerFilterTests : AKTestCase
@end

@implementation AKEqualizerFilterTests

- (void)testEqualizerFilter
{
    // Set up performance
    TestEqualizerFilterInstrument *testInstrument = [[TestEqualizerFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"EqualizerFilter"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"b998e955e3a7d1564aa4e1f6f9a0d925");
}

@end

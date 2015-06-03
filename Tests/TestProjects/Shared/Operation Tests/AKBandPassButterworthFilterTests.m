//
//  AKBandPassButterworthFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestBandPassButterworthFilterInstrument : AKInstrument
@end

@implementation TestBandPassButterworthFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                         secondPoint:akp(10000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(2000)
                                                   secondPoint:akp(20)
                                         durationBetweenPoints:akp(testDuration)];
        AKBandPassButterworthFilter *bandPassButterworthFilter = [[AKBandPassButterworthFilter alloc] initWithInput:mono];
        bandPassButterworthFilter.centerFrequency = centerFrequency;
        bandPassButterworthFilter.bandwidth = bandwidth;

        [self setAudioOutput:bandPassButterworthFilter];
    }
    return self;
}

@end

@interface AKBandPassButterworthFilterTests : AKTestCase
@end

@implementation AKBandPassButterworthFilterTests

- (void)testBandPassButterworthFilter
{
    // Set up performance
    TestBandPassButterworthFilterInstrument *testInstrument = [[TestBandPassButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"BandPassButterworthFilter"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForFile:outputFile], @"9f0e6485d779a6cf4328fb3fe9fb99e1");
}

@end

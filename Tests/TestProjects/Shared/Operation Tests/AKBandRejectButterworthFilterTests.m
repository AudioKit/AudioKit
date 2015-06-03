//
//  AKBandRejectButterworthFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestBandRejectButterworthFilterInstrument : AKInstrument
@end

@implementation TestBandRejectButterworthFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                         secondPoint:akp(1000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(100)
                                                   secondPoint:akp(2000)
                                         durationBetweenPoints:akp(testDuration)];
        AKBandRejectButterworthFilter *bandRejectButterworthFilter = [[AKBandRejectButterworthFilter alloc] initWithInput:mono];
        bandRejectButterworthFilter.centerFrequency = centerFrequency;
        bandRejectButterworthFilter.bandwidth = bandwidth;

        [self setAudioOutput:bandRejectButterworthFilter];
    }
    return self;
}

@end

@interface AKBandRejectButterworthFilterTests : AKTestCase
@end

@implementation AKBandRejectButterworthFilterTests

- (void)testBandRejectButterworthFilter
{
    // Set up performance
    TestBandRejectButterworthFilterInstrument *testInstrument = [[TestBandRejectButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"BandRejectButterworthFilter"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForFile:outputFile], @"13a895c3df53cfc3ff8b48484dcb082c");
}

@end

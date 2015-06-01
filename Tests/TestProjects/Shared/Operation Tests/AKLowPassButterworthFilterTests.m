//
//  AKLowPassButterworthFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestLowPassButterworthFilterInstrument : AKInstrument
@end

@implementation TestLowPassButterworthFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(2000)
                                                         secondPoint:akp(0)
                                               durationBetweenPoints:akp(testDuration)];

        AKLowPassButterworthFilter *lowPassButterworthFilter = [[AKLowPassButterworthFilter alloc] initWithInput:mono];
        lowPassButterworthFilter.cutoffFrequency = cutoffFrequency;

        [self setAudioOutput:lowPassButterworthFilter];
    }
    return self;
}

@end

@interface AKLowPassButterworthFilterTests : AKTestCase
@end

@implementation AKLowPassButterworthFilterTests

- (void)testLowPassButterworthFilter
{
    // Set up performance
    TestLowPassButterworthFilterInstrument *testInstrument = [[TestLowPassButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"LowPassButterworthFilter"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"8a380692aece6c3714f68dcb6c54b8a6");
}

@end

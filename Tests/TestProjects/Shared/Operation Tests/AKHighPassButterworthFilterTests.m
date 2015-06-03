//
//  AKHighPassButterworthFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestHighPassButterworthFilterInstrument : AKInstrument
@end

@implementation TestHighPassButterworthFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                         secondPoint:akp(5000)
                                               durationBetweenPoints:akp(testDuration)];

        AKHighPassButterworthFilter *highPassButterworthFilter = [[AKHighPassButterworthFilter alloc] initWithInput:mono];
        highPassButterworthFilter.cutoffFrequency = cutoffFrequency;

        [self setAudioOutput:highPassButterworthFilter];
    }
    return self;
}

@end

@interface AKHighPassButterworthFilterTests : AKTestCase
@end

@implementation AKHighPassButterworthFilterTests

- (void)testHighPassButterworthFilter
{
    // Set up performance
    TestHighPassButterworthFilterInstrument *testInstrument = [[TestHighPassButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"43b7b629cb436b983a2f3803bbcd918a");
}

@end

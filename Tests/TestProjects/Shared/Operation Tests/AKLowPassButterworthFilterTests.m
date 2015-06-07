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

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"8a380692aece6c3714f68dcb6c54b8a6");
}

- (void)testPresetBassHeavyFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKLowPassButterworthFilter *presetFilter = [AKLowPassButterworthFilter presetBassHeavyFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"996736c8e434131ad41da020a1a02499");
}

- (void)testPresetMildBassFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKLowPassButterworthFilter *presetFilter = [AKLowPassButterworthFilter presetMildBassFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"c34676b2b40aa7e01024955410be5d51");
}

@end

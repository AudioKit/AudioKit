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

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"9f0e6485d779a6cf4328fb3fe9fb99e1");
}

- (void)testPresetBassHeavyFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKBandPassButterworthFilter *presetFilter = [AKBandPassButterworthFilter presetBassHeavyFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"35fcb33a04f4e1a569167a7ef9df345a");
}

- (void)testPresetTrebleHeavyFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKBandPassButterworthFilter *presetFilter = [AKBandPassButterworthFilter presetTrebleHeavyFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"4901ec96a2dd5afbc8f23423da09ccfd");
}

@end

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

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"13a895c3df53cfc3ff8b48484dcb082c");
}

- (void)testPresetBassRejectFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKBandRejectButterworthFilter *presetFilter = [AKBandRejectButterworthFilter presetBassRejectFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"33b325d02dae11c9fb8b2b31c552570c");
}

- (void)testPresetTrebleRejectFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKBandRejectButterworthFilter *presetFilter = [AKBandRejectButterworthFilter presetTrebleRejectFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"3e51deffda855c64f985d72f316228ca");
}

@end

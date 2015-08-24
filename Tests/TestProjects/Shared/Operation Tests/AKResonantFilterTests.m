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

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"7f168a952d7c1272ce811986aa54ab4b");
}

- (void)testPresetHighBassFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKResonantFilter *presetFilter = [AKResonantFilter presetHighBassFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"0e80f36f4a461d8023b3e8c506e68b6c");
}

- (void)testPresetHighTrebleFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKResonantFilter *presetFilter = [AKResonantFilter presetHighTrebleFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"06843635f8ef8f4a90e6876636f94ef4");
}

- (void)testPresetMuffledFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKResonantFilter *presetFilter = [AKResonantFilter presetMuffledFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"c9428132d0ba79f3de5a74b628636383");
}

@end

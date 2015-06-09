//
//  AKCombFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestCombFilterInstrument : AKInstrument
@end

@implementation TestCombFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *reverbDuration = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                         secondPoint:akp(3)
                                               durationBetweenPoints:akp(testDuration)];
        AKCombFilter *combFilter = [[AKCombFilter alloc] initWithInput:mono];
        combFilter.reverbDuration = reverbDuration;

        [self setAudioOutput:combFilter];
    }
    return self;
}

@end

@interface AKCombFilterTests : AKTestCase
@end

@implementation AKCombFilterTests

- (void)testCombFilter
{
    // Set up performance
    TestCombFilterInstrument *testInstrument = [[TestCombFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"e07aafe89f4d028ad2c29869bfce310f");
}

- (void)testPresetShuffleFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKCombFilter *presetFilter = [AKCombFilter presetShuffleFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"d87c7f31533ae17734d64453dbd9b8c4");
}

- (void)testPresetSpringFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKCombFilter *presetFilter = [AKCombFilter presetSpringFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"ba340f4922d3c76965f7943e7aece3d8");
}

@end

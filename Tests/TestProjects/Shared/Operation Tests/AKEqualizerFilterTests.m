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

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"b998e955e3a7d1564aa4e1f6f9a0d925");
}

- (void)testNarrowHighFrequencyNotchFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKEqualizerFilter *presetFilter = [AKEqualizerFilter presetNarrowHighFrequencyNotchFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"61f8d8f52d31ed65034497353bfc87ea");
}

- (void)testNarrowLowFrequencyNotchFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKEqualizerFilter *presetFilter = [AKEqualizerFilter presetNarrowLowFrequencyNotchFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"17a3a6e02d968d51c6b7a52f0e6eb113");
}

- (void)testWideHighFrequencyNotchFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKEqualizerFilter *presetFilter = [AKEqualizerFilter presetWideHighFrequencyNotchFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"cf01351c87d9e600714f42bdd3414695");
}

- (void)testWideLowFrequencyNotchFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKEqualizerFilter *presetFilter = [AKEqualizerFilter presetWideLowFrequencyNotchFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"e82b45c55829d62ffa93a38a67a51654");
}

@end

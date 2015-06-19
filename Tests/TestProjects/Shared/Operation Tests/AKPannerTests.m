//
//  AKPannerTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestPannerInstrument : AKInstrument
@end

@implementation TestPannerInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKOscillator *panAmount = [AKOscillator oscillator];
        panAmount.frequency = akp(1);
        panAmount.amplitude = akp(1);

        AKOscillator *audioSource = [AKOscillator oscillator];

        AKPanner *panner = [[AKPanner alloc] initWithInput:audioSource];
        panner.pan = panAmount;

        [self setAudioOutput:panner];
    }
    return self;
}

@end

@interface AKPannerTests : AKTestCase
@end

@implementation AKPannerTests

- (void)testPanner
{
    // Set up performance
    TestPannerInstrument *testInstrument = [[TestPannerInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"825a42c1c9ff5fb3aa1703b2220eecbf");
}

- (void)testHardLeftPanner
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKPanner *presetPanner = [AKPanner presetDefaultHardLeftWithInput:mono];
    [testInstrument setAudioOutput:presetPanner];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"8617d49bc5e7d5d90ade1f3a4ed53125");
}

- (void)testCenteredPanner
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKPanner *presetPanner = [AKPanner presetDefaultCenteredWithInput:mono];
    [testInstrument setAudioOutput:presetPanner];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"e93845d0b431e35ce8a2777aeff29053");
}

- (void)testHardRightPanner
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKPanner *presetPanner = [AKPanner presetDefaultHardRighWithInput:mono];
    [testInstrument setAudioOutput:presetPanner];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"8e411f79fffa99dfe3be682ec7333ef7");
}

@end

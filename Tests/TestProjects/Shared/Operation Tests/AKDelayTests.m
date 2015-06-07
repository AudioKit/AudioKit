//
//  AKDelayTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDelayInstrument : AKInstrument
@end

@implementation TestDelayInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *feedbackLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                      secondPoint:akp(1)
                                            durationBetweenPoints:akp(testDuration)];

        AKDelay *delay = [[AKDelay alloc] initWithInput:mono
                                              delayTime:akp(0.1)
                                               feedback:feedbackLine];
        AKMix *mix = [[AKMix alloc] initWithInput1:mono
                                            input2:delay
                                           balance:akp(0.5)];

        [self setAudioOutput:mix];
    }
    return self;
}

@end

@interface AKDelayTests : AKTestCase
@end

@implementation AKDelayTests

- (void)testDelay
{
    // Set up performance
    TestDelayInstrument *testInstrument = [[TestDelayInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"bf20742b607230e68b7f55b0291f92d5");
}

- (void)testPresetChoppedDelayWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDelay *presetReverb = [AKDelay presetChoppedDelayWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"c27ec0b5446768600bd74498367e89d9");
}

- (void)testPresetRhythmicAttackDelayWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDelay *presetReverb = [AKDelay presetRhythmicAttackDelayWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"936692f1e8175ac2d6acffa3c2a909c8");
}

- (void)testPresetShortAttackDelayWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKDelay *presetReverb = [AKDelay presetShortAttackDelayWithInput:mono];
    [testInstrument setAudioOutput:presetReverb];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"cf3478a12b769ef11f635652e9eacbfb");
}
@end

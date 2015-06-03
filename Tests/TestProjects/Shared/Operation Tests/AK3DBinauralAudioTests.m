//
//  AK3DBinauralAudioTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface Test3DBinauralAudioInstrument : AKInstrument
@end

@implementation Test3DBinauralAudioInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *azimuth = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                 secondPoint:akp(720)
                                       durationBetweenPoints:akp(testDuration)];

        AK3DBinauralAudio *binauralAudio = [[AK3DBinauralAudio alloc] initWithInput:mono];
        binauralAudio.azimuth = azimuth;

        [self setAudioOutput:binauralAudio];
    }
    return self;
}

@end

@interface AK3DBinauralAudioTests : AKTestCase
@end

@implementation AK3DBinauralAudioTests

- (void)test3DBinauralAudio
{
    // Set up performance
    Test3DBinauralAudioInstrument *testInstrument = [[Test3DBinauralAudioInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"688ffe3ec5c35833954f039e8a21aa19");
}

@end

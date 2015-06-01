//
//  AKReverbTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestReverbInstrument : AKInstrument
@end

@implementation TestReverbInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *feedback = [[AKLine alloc] initWithFirstPoint:akp(0.5)
                                                  secondPoint:akp(1)
                                        durationBetweenPoints:akp(testDuration)];
        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(100)
                                                         secondPoint:akp(10000)
                                               durationBetweenPoints:akp(testDuration)];
        AKReverb *reverb = [[AKReverb alloc] initWithInput:mono];
        reverb.feedback = feedback;
        reverb.cutoffFrequency = cutoffFrequency;

        AKMix *mixLeft  = [[AKMix alloc] initWithInput1:mono input2:reverb.leftOutput  balance:akp(0.5)];
        AKMix *mixRight = [[AKMix alloc] initWithInput1:mono input2:reverb.rightOutput balance:akp(0.5)];

        AKStereoAudio *output = [[AKStereoAudio alloc] initWithLeftAudio:mixLeft rightAudio:mixRight];
        [self setStereoAudioOutput:output];
    }
    return self;
}

@end

@interface AKReverbTests : AKTestCase
@end

@implementation AKReverbTests

- (void)testReverb
{
    // Set up performance
    TestReverbInstrument *testInstrument = [[TestReverbInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"Reverb"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"b0a067e833d8b0dc7bac7d1ed09db404");
}

@end

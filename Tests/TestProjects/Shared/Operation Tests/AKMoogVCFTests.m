//
//  AKMoogVCFTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestMoogVCFInstrument : AKInstrument
@end

@implementation TestMoogVCFInstrument

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

        AKMoogVCF *moogVCF = [[AKMoogVCF alloc] initWithInput:mono];
        moogVCF.cutoffFrequency = cutoffFrequency;

        [self setAudioOutput:moogVCF];
    }
    return self;
}

@end

@interface AKMoogVCFTests : AKTestCase
@end

@implementation AKMoogVCFTests

- (void)testMoogVCF
{
    // Set up performance
    TestMoogVCFInstrument *testInstrument = [[TestMoogVCFInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"MoogVCF"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForFile:outputFile], @"5bc5b6b23038bff35bba2d5bff1fe7d1");
}

@end

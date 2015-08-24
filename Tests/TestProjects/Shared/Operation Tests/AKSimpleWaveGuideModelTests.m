//
//  AKSimpleWaveGuideModelTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestSimpleWaveGuideModelInstrument : AKInstrument
@end

@implementation TestSimpleWaveGuideModelInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoff = [[AKLine alloc] initWithFirstPoint:akp(1000)
                                                secondPoint:akp(5000)
                                      durationBetweenPoints:akp(testDuration)];
        AKLine *frequency = [[AKLine alloc] initWithFirstPoint:akp(12)
                                                   secondPoint:akp(1000)
                                         durationBetweenPoints:akp(testDuration)];
        AKLine *feedback = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                  secondPoint:akp(0.8)
                                        durationBetweenPoints:akp(testDuration)];

        AKSimpleWaveGuideModel *simpleWaveGuideModel = [[AKSimpleWaveGuideModel alloc] initWithInput:mono];
        simpleWaveGuideModel.cutoff    = cutoff;
        simpleWaveGuideModel.frequency = frequency;
        simpleWaveGuideModel.feedback  = feedback;

        [self setAudioOutput:simpleWaveGuideModel];
    }
    return self;
}

@end

@interface AKSimpleWaveGuideModelTests : AKTestCase
@end

@implementation AKSimpleWaveGuideModelTests

- (void)testSimpleWaveGuideModel
{
    // Set up performance
    TestSimpleWaveGuideModelInstrument *testInstrument = [[TestSimpleWaveGuideModelInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"347cccc221b25743c4ebf2bf4f538d8a");
}

@end

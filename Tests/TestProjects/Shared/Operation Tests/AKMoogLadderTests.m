//
//  AKMoogLadderTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestMoogLadderInstrument : AKInstrument
@end

@implementation TestMoogLadderInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(100)
                                                         secondPoint:akp(10000)
                                               durationBetweenPoints:akp(testDuration)];

        AKLine *resonance = [[AKLine alloc] initWithFirstPoint:akp(0.1)
                                                   secondPoint:akp(1)
                                         durationBetweenPoints:akp(testDuration)];

        AKMoogLadder *moogLadder = [[AKMoogLadder alloc] initWithInput:mono];
        moogLadder.cutoffFrequency = cutoffFrequency;
        moogLadder.resonance = resonance;

        [self setAudioOutput:moogLadder];
    }
    return self;
}

@end

@interface AKMoogLadderTests : AKTestCase
@end

@implementation AKMoogLadderTests

- (void)testMoogLadder
{
    // Set up performance
    TestMoogLadderInstrument *testInstrument = [[TestMoogLadderInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"588e341dd4e6d136cc14fc08175e3338");
}

- (void)testBassHeavyFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKMoogLadder *presetFilter = [AKMoogLadder presetBassHeavyFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"39a9bb48c894a3afe0e58ee151b2605f");
}

- (void)testUnderwaterFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKMoogLadder *presetFilter = [AKMoogLadder presetUnderwaterFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"14949090ec9615708ef958b6e5634fda");
}

@end

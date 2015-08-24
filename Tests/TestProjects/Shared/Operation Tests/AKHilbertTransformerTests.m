//
//  AKHilbertTransformerTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestHilbertTransformerInstrument : AKInstrument
@end

@implementation TestHilbertTransformerInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *frequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(2000)
                                         durationBetweenPoints:akp(testDuration)];

        AKHilbertTransformer *hilbertTransformer = [[AKHilbertTransformer alloc] initWithInput:mono
                                                                                     frequency:frequency];
        [self setAudioOutput:hilbertTransformer];
    }
    return self;
}

@end

@interface AKHilbertTransformerTests : AKTestCase
@end

@implementation AKHilbertTransformerTests

- (void)testHilbertTransformer
{
    // Set up performance
    TestHilbertTransformerInstrument *testInstrument = [[TestHilbertTransformerInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"9158222aee0b6e4474b18aa1eae6c603");
}

- (void)testAlienSpaceshipFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKHilbertTransformer *presetFilter = [AKHilbertTransformer presetAlienSpaceshipFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"cbc16def3c8f628d4701ae7e84d6258c");
}

- (void)testMosquitoFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKHilbertTransformer *presetFilter = [AKHilbertTransformer presetMosquitoFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"1a294bdf8d517fafe06ecebb3f7c86d7");
}

@end

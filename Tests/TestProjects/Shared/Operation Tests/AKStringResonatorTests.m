//
//  AKStringResonatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestStringResonatorInstrument : AKInstrument
@end

@implementation TestStringResonatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *fundamentalFrequency = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                              secondPoint:akp(1000)
                                                    durationBetweenPoints:akp(testDuration)];
        AKStringResonator *stringResonator = [[AKStringResonator alloc] initWithInput:mono];
        stringResonator.fundamentalFrequency = fundamentalFrequency;

        [self setAudioOutput:stringResonator];
    }
    return self;
}

@end

@interface AKStringResonatorTests : AKTestCase
@end

@implementation AKStringResonatorTests

- (void)testStringResonator
{
    // Set up performance
    TestStringResonatorInstrument *testInstrument = [[TestStringResonatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"60df7446f32abc45a91b5762d20325c6");
}

- (void)testPresetMachineResonatorWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKStringResonator *presetFilter = [AKStringResonator presetMachineResonatorWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"99d373ca692a400542b57f7306989a26");
}

@end

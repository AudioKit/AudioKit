//
//  AKHighPassButterworthFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestHighPassButterworthFilterInstrument : AKInstrument
@end

@implementation TestHighPassButterworthFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *cutoffFrequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                         secondPoint:akp(5000)
                                               durationBetweenPoints:akp(testDuration)];

        AKHighPassButterworthFilter *highPassButterworthFilter = [[AKHighPassButterworthFilter alloc] initWithInput:mono];
        highPassButterworthFilter.cutoffFrequency = cutoffFrequency;

        [self setAudioOutput:highPassButterworthFilter];
    }
    return self;
}

@end

@interface AKHighPassButterworthFilterTests : AKTestCase
@end

@implementation AKHighPassButterworthFilterTests

- (void)testHighPassButterworthFilter
{
    // Set up performance
    TestHighPassButterworthFilterInstrument *testInstrument = [[TestHighPassButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"43b7b629cb436b983a2f3803bbcd918a");
}

- (void)testPresetExtremeFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKHighPassButterworthFilter *presetFilter = [AKHighPassButterworthFilter presetExtremeFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"80af5ea17b1ab8ba6d7ecc3d348cf24b");
}

- (void)testPresetModerateFilterWithInput
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
    audio.loop = YES;
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
    
    AKInstrument *testInstrument = [AKInstrument instrument];
    AKHighPassButterworthFilter *presetFilter = [AKHighPassButterworthFilter presetModerateFilterWithInput:mono];
    [testInstrument setAudioOutput:presetFilter];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument play];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:2.0], @"40bcc339b8addb9e655d7f8b2b960e62");
}

@end

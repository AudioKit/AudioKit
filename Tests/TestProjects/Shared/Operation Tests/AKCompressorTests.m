//
//  AKCompressorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestCompressorInstrument : AKInstrument
@end

@implementation TestCompressorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *compressionRatio = [[AKLine alloc] initWithFirstPoint:akp(0.5)
                                                          secondPoint:akp(2)
                                                durationBetweenPoints:akp(testDuration)];
        AKLine *attackTime = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                    secondPoint:akp(1)
                                          durationBetweenPoints:akp(testDuration)];
        AKCompressor *compressor = [[AKCompressor alloc] initWithInput:mono controllingInput:mono];
        compressor.compressionRatio = compressionRatio;
        compressor.attackTime = attackTime;

        AKBalance *balance = [[AKBalance alloc] initWithInput:compressor comparatorAudioSource:mono];

        [self setAudioOutput:balance];
    }
    return self;
}

@end

@interface AKCompressorTests : AKTestCase
@end

@implementation AKCompressorTests

- (void)testCompressor
{
    // Set up performance
    TestCompressorInstrument *testInstrument = [[TestCompressorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"024e300deb0460f0c32864403355bc76");
}

@end

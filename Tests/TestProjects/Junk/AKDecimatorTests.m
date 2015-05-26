//
//  AKDecimatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDecimatorInstrument : AKInstrument
@end

@implementation TestDecimatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *bitDepth = [[AKLine alloc] initWithFirstPoint:akp(24)
                                                  secondPoint:akp(18)
                                        durationBetweenPoints:akp(testDuration)];
        AKLine *sampleRate = [[AKLine alloc] initWithFirstPoint:akp(5000)
                                                    secondPoint:akp(1000)
                                          durationBetweenPoints:akp(testDuration)];
        AKDecimator *decimator = [[AKDecimator alloc] initWithInput:mono];
        decimator.bitDepth = bitDepth;
        decimator.sampleRate = sampleRate;
        
        [self setAudioOutput:decimator];
    }
    return self;
}

@end

@interface AKDecimatorTests : AKTestCase
@end

@implementation AKDecimatorTests

- (void)testDecimator
{
    // Set up performance
    TestDecimatorInstrument *testInstrument = [[TestDecimatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Decimator.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"a62dd414fe5ebb6e21b3099ce1287e7e");
}

@end

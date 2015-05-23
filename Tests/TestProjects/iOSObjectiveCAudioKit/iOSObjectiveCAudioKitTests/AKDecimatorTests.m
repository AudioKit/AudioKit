//
//  AKDecimatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AKFoundation.h"
#import "NSData+MD5.h"

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

@interface AKDecimatorTests : XCTestCase
@end

@implementation AKDecimatorTests

- (void)testDecimator {
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Decimator.aiff", NSTemporaryDirectory()];
    TestDecimatorInstrument *decimator = [[TestDecimatorInstrument alloc] init];
    [AKOrchestra addInstrument:decimator];
    [decimator playForDuration:testDuration];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSLog(@"Decimator MD5: %@", [nsData MD5]);
    XCTAssertTrue([[nsData MD5] isEqualToString:@"a62dd414fe5ebb6e21b3099ce1287e7e"]);
}

@end

//
//  AK3DBinauralAudioTests.m
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

@interface Test3DBinauralAudioInstrument : AKInstrument
@end

@implementation Test3DBinauralAudioInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *azimuth = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                  secondPoint:akp(720)
                                        durationBetweenPoints:akp(testDuration)];
        
        AK3DBinauralAudio *binauralAudio = [[AK3DBinauralAudio alloc] initWithInput:mono];
        binauralAudio.azimuth = azimuth;
        
        [self setAudioOutput:binauralAudio];
    }
    return self;
}

@end

@interface AK3DBinauralAudioTests : XCTestCase
@end

@implementation AK3DBinauralAudioTests

- (void)test3DBinauralAudio
{
    // Set up performance
    Test3DBinauralAudioInstrument *testInstrument = [[Test3DBinauralAudioInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-3DBinauralAudio.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"688ffe3ec5c35833954f039e8a21aa19");
}

@end

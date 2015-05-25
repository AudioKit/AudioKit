//
//  AKHighPassButterworthFilterTests.m
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

@interface AKHighPassButterworthFilterTests : XCTestCase
@end

@implementation AKHighPassButterworthFilterTests

- (void)testHighPassButterworthFilter
{
    // Set up performance
    TestHighPassButterworthFilterInstrument *testInstrument = [[TestHighPassButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-HighPassButterworthFilter.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"43b7b629cb436b983a2f3803bbcd918a");
}

@end

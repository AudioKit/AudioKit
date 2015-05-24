//
//  AKBandPassButterworthFilterTests.m
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

@interface TestBandPassButterworthFilterInstrument : AKInstrument
@end

@implementation TestBandPassButterworthFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                         secondPoint:akp(10000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(2000)
                                                   secondPoint:akp(20)
                                         durationBetweenPoints:akp(testDuration)];
        AKBandPassButterworthFilter *bandPassButterworthFilter = [[AKBandPassButterworthFilter alloc] initWithInput:mono];
        bandPassButterworthFilter.centerFrequency = centerFrequency;
        bandPassButterworthFilter.bandwidth = bandwidth;
        
        [self setAudioOutput:bandPassButterworthFilter];
    }
    return self;
}

@end

@interface AKBandPassButterworthFilterTests : XCTestCase
@end

@implementation AKBandPassButterworthFilterTests

- (void)testBandPassButterworthFilter
{
    // Set up performance
    TestBandPassButterworthFilterInstrument *testInstrument = [[TestBandPassButterworthFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-BandPassButterworthFilter.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"4370e73843a2e7f3731e4f9e332f6062");
}

@end

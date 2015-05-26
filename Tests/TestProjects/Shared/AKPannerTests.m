//
//  AKPannerTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestPannerInstrument : AKInstrument
@end

@implementation TestPannerInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {


        AKOscillator *panAmount = [AKOscillator oscillator];
        panAmount.frequency = akp(1);
        panAmount.amplitude = akp(1);

        AKOscillator *audioSource = [AKOscillator oscillator];

        AKPanner *panner = [[AKPanner alloc] initWithInput:audioSource];
        panner.pan = panAmount;

        [self setAudioOutput:panner];
    }
    return self;
}

@end

@interface AKPannerTests : AKTestCase
@end

@implementation AKPannerTests

- (void)testPanner
{
    // Set up performance
    TestPannerInstrument *testInstrument = [[TestPannerInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Panner.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSArray *validMD5s = @[@"68f0b60fd92ef8366c0ad239aa4b6999",
                           @"825a42c1c9ff5fb3aa1703b2220eecbf"];
    XCTAssertTrue([validMD5s containsObject:[nsData MD5]]);
}

@end

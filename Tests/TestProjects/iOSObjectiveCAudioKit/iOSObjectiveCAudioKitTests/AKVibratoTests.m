//
//  AKVibratoTests.m
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

@interface TestVibratoInstrument : AKInstrument
@end

@implementation TestVibratoInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        AKVibrato *vibrato = [AKVibrato vibrato];
        vibrato.averageAmplitude = akp(20);
        
        AKOscillator *sine = [AKOscillator oscillator];
        sine.frequency = [akp(440) plus:vibrato];
        
        [self setAudioOutput:sine];
    }
    return self;
}

@end

@interface AKVibratoTests : XCTestCase
@end

@implementation AKVibratoTests

- (void)testVibrato
{
    // Set up performance
    TestVibratoInstrument *testInstrument = [[TestVibratoInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Vibrato.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"3cd5d4aac398e56d527230436bc06358");
}

@end

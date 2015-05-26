//
//  AKFMOscillatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestFMOscillatorInstrument : AKInstrument
@end

@implementation TestFMOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        AKLine *frequencyLine = [[AKLine alloc] initWithFirstPoint:akp(10)
                                                       secondPoint:akp(880)
                                             durationBetweenPoints:akp(testDuration)];
        AKLine *carrierMultiplierLine = [[AKLine alloc] initWithFirstPoint:akp(2)
                                                               secondPoint:akp(0)
                                                     durationBetweenPoints:akp(testDuration)];
        AKLine *modulatingMultiplierLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                                  secondPoint:akp(2)
                                                        durationBetweenPoints:akp(testDuration)];
        AKLine *indexLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(30)
                                         durationBetweenPoints:akp(testDuration)];
        // Instrument Definition
        AKFMOscillator *oscillator = [AKFMOscillator oscillator];
        oscillator.baseFrequency = frequencyLine;
        oscillator.carrierMultiplier = carrierMultiplierLine;
        oscillator.modulatingMultiplier = modulatingMultiplierLine;
        oscillator.modulationIndex = indexLine;
        
        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKFMOscillatorTests : AKTestCase
@end

@implementation AKFMOscillatorTests

- (void)testFMOscillator
{
    // Set up performance
    TestFMOscillatorInstrument *testInstrument = [[TestFMOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-FMOscillator.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"dfe4b8c87584f8847acc1352ba3b2bf2");
}

@end

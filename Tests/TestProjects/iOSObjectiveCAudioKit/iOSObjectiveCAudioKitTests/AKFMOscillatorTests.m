//
//  AKFMOscillatorTests.m
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

@interface AKFMOscillatorTests : XCTestCase
@end

@implementation AKFMOscillatorTests

- (void)testFMOscillator {
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-FMOscillator.aiff", NSTemporaryDirectory()];
    TestFMOscillatorInstrument *fm = [[TestFMOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:fm];
    [fm playForDuration:testDuration];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSLog(@"%@", [nsData MD5]);
    XCTAssertTrue([[nsData MD5] isEqualToString:@"99becb404ef25b519470c6768ad47a84"]);
}



@end

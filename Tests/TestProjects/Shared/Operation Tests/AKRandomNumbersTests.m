//
//  AKRandomNumbersTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestRandomNumbersInstrument : AKInstrument
@end

@implementation TestRandomNumbersInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKLine *baseLine = [[AKLine alloc] initWithFirstPoint:akp(200) secondPoint:akp(1000) durationBetweenPoints:akp(testDuration)];
        AKRandomNumbers *randomWidth = [[AKRandomNumbers alloc] init];

        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = [akp(44) plus:[randomWidth scaledBy:baseLine]];
        
        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKRandomNumbersTests : AKTestCase
@end

@implementation AKRandomNumbersTests

- (void)testRandomNumbers
{
    // Set up performance
    TestRandomNumbersInstrument *testInstrument = [[TestRandomNumbersInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"RandomNumbers"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSArray *validMD5s = @[@"ff97587d06accd8a9d9f1500e70401b0",
                           @"f475ac4518a11e1f2438a0f6acd97859"];
    XCTAssertTrue([validMD5s containsObject:[nsData MD5]]);
}

@end

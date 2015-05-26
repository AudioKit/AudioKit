//
//  AKBalanceTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestBalanceInstrument : AKInstrument
@end

@implementation TestBalanceInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        AKOscillator *amplitude = [AKOscillator oscillator];
        amplitude.frequency = akp(1);
        
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.amplitude = amplitude;
        
        AKFMOscillator *synth = [AKFMOscillator oscillator];
        AKBalance *balance = [[AKBalance alloc] initWithInput:synth comparatorAudioSource:oscillator];
        
        [self setAudioOutput:balance];
    }
    return self;
}

@end

@interface AKBalanceTests : AKTestCase
@end

@implementation AKBalanceTests

- (void)testBalance
{
    // Set up performance
    TestBalanceInstrument *testInstrument = [[TestBalanceInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Balance.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSArray *validMD5s = @[@"90537e563b9df281b45b2707187e670b",
                           @"9dccf5d9465f177b7ae19a0de31670e3"];
    XCTAssertTrue([validMD5s containsObject:[nsData MD5]]);
}

@end

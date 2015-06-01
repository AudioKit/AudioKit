//
//  AKOscillatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestOscillatorInstrument : AKInstrument
@end

@implementation TestOscillatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        AKOscillator *frequencyOscillator = [AKOscillator oscillator];
        frequencyOscillator.frequency = akp(2);
        
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = [[frequencyOscillator scaledBy:akp(110)] plus:akp(440)];
        
        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKOscillatorTests : AKTestCase
@end

@implementation AKOscillatorTests

- (void)testOscillator
{
    // Set up performance
    TestOscillatorInstrument *testInstrument = [[TestOscillatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"Oscillator"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSArray *validMD5s = @[@"2b8e98364007e66542ee2e92f44d789a",
                           @"95184436da24aa6c7b65b80b48f916e8"];
    XCTAssertTrue([validMD5s containsObject:[nsData MD5]]);
}

@end

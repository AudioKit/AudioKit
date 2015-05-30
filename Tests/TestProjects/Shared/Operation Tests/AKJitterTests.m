//
//  AKJitterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestJitterInstrument : AKInstrument
@end

@implementation TestJitterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKJitter *jitter = [AKJitter jitter];
        jitter.amplitude = akp(3000);
        
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = jitter;
        
        [self setAudioOutput:oscillator];
    }
    return self;
}

@end

@interface AKJitterTests : AKTestCase
@end

@implementation AKJitterTests

- (void)testJitter
{
    // Set up performance
    TestJitterInstrument *testInstrument = [[TestJitterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Jitter.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSArray *validMD5s = @[@"52dcc208f35a0bb5672e37c35e77e807",
                           @"57be4e735c6d3d830569570e8163881b"];
    XCTAssertTrue([validMD5s containsObject:[nsData MD5]]);
}

@end

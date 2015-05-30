//
//  AKDelayTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDelayInstrument : AKInstrument
@end

@implementation TestDelayInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *feedbackLine = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                      secondPoint:akp(1)
                                            durationBetweenPoints:akp(testDuration)];
        
        AKDelay *delay = [[AKDelay alloc] initWithInput:mono
                                              delayTime:akp(0.1)
                                               feedback:feedbackLine];
        AKMix *mix = [[AKMix alloc] initWithInput1:mono
                                            input2:delay
                                           balance:akp(0.5)];
        
        [self setAudioOutput:mix];
    }
    return self;
}

@end

@interface AKDelayTests : AKTestCase
@end

@implementation AKDelayTests

- (void)testDelay
{
    // Set up performance
    TestDelayInstrument *testInstrument = [[TestDelayInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Delay.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"bf20742b607230e68b7f55b0291f92d5");
}

@end

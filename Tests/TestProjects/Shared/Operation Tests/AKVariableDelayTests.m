//
//  AKVariableDelayTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestVariableDelayInstrument : AKInstrument
@end

@implementation TestVariableDelayInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *delayTime = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                      secondPoint:akp(0.2)
                                            durationBetweenPoints:akp(testDuration)];

        AKVariableDelay *delay = [[AKVariableDelay alloc] initWithInput:mono];
        delay.delayTime = delayTime;
        AKMix *mix = [[AKMix alloc] initWithInput1:mono
                                            input2:delay
                                           balance:akp(0.5)];

        [self setAudioOutput:mix];
    }
    return self;
}

@end

@interface AKVariableDelayTests : AKTestCase
@end

@implementation AKVariableDelayTests

- (void)testVariableDelay
{
    // Set up performance
    TestVariableDelayInstrument *testInstrument = [[TestVariableDelayInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"VariableDelay"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSArray *validMD5s = @[@"b29c592cc35527aa0c335eb9c0d3f211",
                           @"212203a0a1b4ada367be49a10954ea2f"];
    XCTAssertTrue([validMD5s containsObject:[self md5ForFile:outputFile]]);
}

@end

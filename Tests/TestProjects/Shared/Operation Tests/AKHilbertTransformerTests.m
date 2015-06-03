//
//  AKHilbertTransformerTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestHilbertTransformerInstrument : AKInstrument
@end

@implementation TestHilbertTransformerInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKLine *frequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(2000)
                                         durationBetweenPoints:akp(testDuration)];

        AKHilbertTransformer *hilbertTransformer = [[AKHilbertTransformer alloc] initWithInput:mono
                                                                                     frequency:frequency];
        [self setAudioOutput:hilbertTransformer];
    }
    return self;
}

@end

@interface AKHilbertTransformerTests : AKTestCase
@end

@implementation AKHilbertTransformerTests

- (void)testHilbertTransformer
{
    // Set up performance
    TestHilbertTransformerInstrument *testInstrument = [[TestHilbertTransformerInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Render audio output
    NSString *outputFile = [self outputFileWithName:@"HilbertTransformer"];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];

    // Check output
    NSArray *validMD5s = @[@"9158222aee0b6e4474b18aa1eae6c603",
                           @"d7e825a3c9a98a2001a956250a1c4983"];
    XCTAssertTrue([validMD5s containsObject:[self md5ForFile:outputFile]]);
}

@end

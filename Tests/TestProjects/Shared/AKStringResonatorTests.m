//
//  AKStringResonatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestStringResonatorInstrument : AKInstrument
@end

@implementation TestStringResonatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *fundamentalFrequency = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                              secondPoint:akp(1000)
                                                    durationBetweenPoints:akp(testDuration)];
        AKStringResonator *stringResonator = [[AKStringResonator alloc] initWithInput:mono];
        stringResonator.fundamentalFrequency = fundamentalFrequency;
        
        [self setAudioOutput:stringResonator];
    }
    return self;
}

@end

@interface AKStringResonatorTests : AKTestCase
@end

@implementation AKStringResonatorTests

- (void)testStringResonator
{
    // Set up performance
    TestStringResonatorInstrument *testInstrument = [[TestStringResonatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-StringResonator.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"60df7446f32abc45a91b5762d20325c6");
}

@end

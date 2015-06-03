//
//  AKMultitapDelayTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestMultitapDelayInstrument : AKInstrument
@end

@implementation TestMultitapDelayInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKMultitapDelay *delay = [[AKMultitapDelay alloc] initWithInput:mono
                                                          firstEchoTime:akp(1)
                                                          firstEchoGain:akp(0.5)];
        [delay addEchoAtTime:akp(1.5) gain:akp(0.25)];
        AKMix *mix = [[AKMix alloc] initWithInput1:mono
                                            input2:delay
                                           balance:akp(0.5)];

        [self setAudioOutput:mix];
    }
    return self;
}

@end

@interface AKMultitapDelayTests : AKTestCase
@end

@implementation AKMultitapDelayTests

- (void)testMultitapDelay
{
    // Set up performance
    TestMultitapDelayInstrument *testInstrument = [[TestMultitapDelayInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"68fd452b84ad5b2c11bf8a557da65c67");
}

@end

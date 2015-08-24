//
//  AKStereoConvolutionTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestStereoConvolutionInstrument : AKInstrument
@end

@implementation TestStereoConvolutionInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        NSString *stereoImpulse = [AKManager pathToSoundFile:@"shortpianohits" ofType:@"aif"];

        AKStereoConvolution *stereoConvolution = [[AKStereoConvolution alloc] initWithInput:[mono scaledBy:akp(0.007)]
                                                                    impulseResponseFilename:stereoImpulse];

        [self setStereoAudioOutput:stereoConvolution];
    }
    return self;
}

@end

@interface AKStereoConvolutionTests : AKTestCase
@end

@implementation AKStereoConvolutionTests

- (void)testStereoConvolution
{
    // Set up performance
    TestStereoConvolutionInstrument *testInstrument = [[TestStereoConvolutionInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"fda24ec8f1ee821d5f74b3b95290cc0b");
}

@end

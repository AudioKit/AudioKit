//
//  AKAntiresonantFilterTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestAntiresonantFilterInstrument : AKInstrument
@end

@implementation TestAntiresonantFilterInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *centerFrequency = [[AKLine alloc] initWithFirstPoint:akp(1)
                                                         secondPoint:akp(5000)
                                               durationBetweenPoints:akp(testDuration)];
        AKLine *bandwidth = [[AKLine alloc] initWithFirstPoint:akp(500)
                                                   secondPoint:akp(0)
                                         durationBetweenPoints:akp(testDuration)];
        AKAntiresonantFilter *filter = [[AKAntiresonantFilter alloc] initWithInput:mono];
        filter.centerFrequency = centerFrequency;
        filter.bandwidth       = bandwidth;
        
        [self setAudioOutput:filter];
    }
    return self;
}

@end

@interface AKAntiresonantFilterTests : AKTestCase
@end

@implementation AKAntiresonantFilterTests

- (void)testAntiresonantFilter
{
    // Set up performance
    TestAntiresonantFilterInstrument *testInstrument = [[TestAntiresonantFilterInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"1ed0bdfac7be5ace532d635186af071d");
}


@end

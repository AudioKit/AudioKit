//
//  AKDropletTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDropletInstrument : AKInstrument
@end

@implementation TestDropletInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKDroplet *droplet = [AKDroplet droplet];
        [self setAudioOutput:droplet];
    }
    return self;
}

@end

@interface AKDropletTests : AKTestCase
@end

@implementation AKDropletTests

- (void)testDroplet
{
    // Set up performance
    TestDropletInstrument *testInstrument = [[TestDropletInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    
    AKPhrase *phrase = [AKPhrase phrase];
    
    for (int i = 0; i < 100; i++) {
        AKNote *note = [[AKNote alloc] init];
        float time = (float)i/100*testDuration;
        [phrase addNote:note atTime:time];
    }
    
    [testInstrument playPhrase:phrase];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-Droplet.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    XCTAssertEqualObjects([nsData MD5], @"3989de991cf548d9555e7beb95281c3a");
}

@end

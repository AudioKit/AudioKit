//
//  AKClipperTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestClipperInstrument : AKInstrument
@end

@implementation TestClipperInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];

        AKClipper *clipper = [[AKClipper alloc] initWithInput:mono];
        clipper.limit = akp(0.4);
 
        [self setAudioOutput:clipper];
    }
    return self;
}

@end

@interface AKClipperTests : AKTestCase
@end

@implementation AKClipperTests

- (void)testClipper
{
    // Set up performance
    TestClipperInstrument *testInstrument = [[TestClipperInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"b14417251923e59d91a16771ed6ea791");
}

@end

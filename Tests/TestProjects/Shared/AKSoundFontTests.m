//
//  AKSoundFontTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestSoundFontInstrument : AKInstrument
@end

@implementation TestSoundFontInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {

        NSString *filename = [AKManager pathToSoundFile:@"07AcousticGuitar" ofType:@"sf2"];
        AKSoundFont *font = [[AKSoundFont alloc] initWithFilename:filename];
        AKSoundFontPlayer *player = [AKSoundFontPlayer playerWithSoundFont:font];
        
        [self setStereoAudioOutput:player];
    }
    return self;
}

@end

@interface AKSoundFontTests : AKTestCase
@end

@implementation AKSoundFontTests

- (void)testSoundFontPlayback
{
    // Set up performance
    TestSoundFontInstrument *testInstrument = [[TestSoundFontInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];

    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"688ffe3ec5c35833954f039e8a21aa19");
}

@end

//
//  AKDistortionTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestDistortionInstrument : AKInstrument
@end

@implementation TestDistortionInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *pregain = [[AKLine alloc] initWithFirstPoint:akp(0.5)
                                                 secondPoint:akp(2)
                                       durationBetweenPoints:akp(testDuration)];
        AKLine *postgain = [[AKLine alloc] initWithFirstPoint:akp(2)
                                                  secondPoint:akp(0.5)
                                        durationBetweenPoints:akp(testDuration)];
        AKLine *shape = [[AKLine alloc] initWithFirstPoint:akp(0)
                                               secondPoint:akp(0.5)
                                     durationBetweenPoints:akp(testDuration)];
        AKDistortion *distortion = [[AKDistortion alloc] initWithInput:mono];
        distortion.pregain = pregain;
        distortion.postgain = postgain;
        distortion.postiveShapeParameter = shape;
        
        [self setAudioOutput:distortion];
    }
    return self;
}

@end

@interface AKDistortionTests : AKTestCase
@end

@implementation AKDistortionTests

- (void)testDistortion
{
    // Set up performance
    TestDistortionInstrument *testInstrument = [[TestDistortionInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Check output
    XCTAssertEqualObjects([self md5ForOutputWithDuration:testDuration], @"c253dae4d21bb34c88c85c551ceecd12");
}

@end

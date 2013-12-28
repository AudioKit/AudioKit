//
//  OCSAudioAnalyzer.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudioAnalyzer.h"
#import "OCSTrackedFrequency.h"
#import "OCSTrackedAmplitude.h"
#import "OCSAssignment.h"

@implementation OCSAudioAnalyzer

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource {
    self = [super init];
    if (self) {
        _trackedFrequency = [[OCSInstrumentProperty alloc] initWithValue:kTrackedFrequencyMin
                                                                minValue:kTrackedFrequencyMin
                                                                maxValue:kTrackedFrequencyMax];
        [self addProperty:_trackedFrequency];
        _trackedAmplitude = [[OCSInstrumentProperty alloc] initWithMinValue:0 maxValue:1];
        [self addProperty:_trackedAmplitude];
        
        
        OCSTrackedFrequency *frequency;
        frequency = [[OCSTrackedFrequency alloc] initWithAudioSource:audioSource
                                                          sampleSize:ocsp(2048)];
        [self connect:frequency];
        [self connect:[[OCSAssignment alloc] initWithOutput:_trackedFrequency
                                                      input:frequency]];
        
        
        OCSTrackedAmplitude *amplitude;
        amplitude = [[OCSTrackedAmplitude alloc] initWithAudioSource:audioSource];
        [self connect:amplitude];
        [self connect:[[OCSAssignment alloc] initWithOutput:_trackedAmplitude
                                                      input:amplitude]];
    }
    return self;
}


@end

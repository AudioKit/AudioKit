//
//  AKAudioAnalyzer.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioAnalyzer.h"
#import "AKTrackedFrequency.h"
#import "AKTrackedAmplitude.h"
#import "AKAssignment.h"

@implementation AKAudioAnalyzer

- (instancetype)initWithAudioSource:(AKAudio *)audioSource {
    self = [super init];
    if (self) {
        _trackedFrequency = [[AKInstrumentProperty alloc] initWithValue:0
                                                                minimum:0
                                                                maximum:2500];
        [self addProperty:_trackedFrequency];
        _trackedAmplitude = [[AKInstrumentProperty alloc] initWithMinimum:0 maximum:1];
        [self addProperty:_trackedAmplitude];
        
        
        AKTrackedFrequency *frequency;
        frequency = [[AKTrackedFrequency alloc] initWithAudioSource:audioSource
                                                         sampleSize:akp(2048)];
        [self connect:frequency];
        [self connect:[[AKAssignment alloc] initWithOutput:_trackedFrequency
                                                     input:frequency]];
        
        AKTrackedAmplitude *amplitude;
        amplitude = [[AKTrackedAmplitude alloc] initWithAudioSource:audioSource];
        [self connect:amplitude];
        [self connect:[[AKAssignment alloc] initWithOutput:_trackedAmplitude
                                                     input:amplitude]];
        [self resetParameter:audioSource];
    }
    return self;
}


@end

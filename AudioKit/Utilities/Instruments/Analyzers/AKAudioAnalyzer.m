//
//  AKAudioAnalyzer.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioAnalyzer.h"

@implementation AKAudioAnalyzer

- (instancetype)initWithInput:(AKAudio *)audioSource {
    self = [super init];
    if (self) {
        _trackedFrequency = [[AKInstrumentProperty alloc] initWithMinimum:0 maximum:2500];
        _trackedAmplitude = [[AKInstrumentProperty alloc] initWithMinimum:0 maximum:1];
        
        AKTrackedFrequency *frequency;
        frequency = [[AKTrackedFrequency alloc] initWithInput:audioSource
                                                   sampleSize:akp(2048)];
        [self setParameter:_trackedFrequency to:frequency];
        
        AKTrackedAmplitude *amplitude;
        amplitude = [[AKTrackedAmplitude alloc] initWithInput:audioSource];
        [self setParameter:_trackedAmplitude to:amplitude];
        
        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:audioSource];
        
        [self resetParameter:audioSource];
    }
    return self;
}


@end

//
//  MicrophoneAnalysisPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "Microphone.h"
#import "AKAudioAnalyzer.h"

@implementation Playground

- (void)run
{
    [super run];

    Microphone *mic = [[Microphone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:mic.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    [analyzer play];
    [mic play];

    [self addPlotForInstrumentProperty:analyzer.trackedAmplitude withLabel:@"Amplitude"];
    [self addPlotForInstrumentProperty:analyzer.trackedFrequency withLabel:@"Frequency"];

    [self addAudioInputRollingWaveformPlot];
    [self addAudioInputPlot];
    [self addAudioInputFFTPlot];
}

@end

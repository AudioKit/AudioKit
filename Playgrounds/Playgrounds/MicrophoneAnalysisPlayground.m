//
//  MicrophoneAnalysisPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithInput:mic.output];
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

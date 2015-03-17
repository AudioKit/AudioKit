//
//  MicrophoneAnalysisPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "AKAudioAnalyzer.h"

@interface VocalInput : AKInstrument
@property (readonly) AKAudio *auxilliaryOutput;
@end

@implementation VocalInput

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:microphone];
    }
    return self;
}

@end

@implementation Playground

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];
    [self addAudioInputPlot];
    
    VocalInput *mic = [[VocalInput alloc] init];
    [AKOrchestra addInstrument:mic];
    AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:mic.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    [analyzer play];
    [mic play];
    [self addPlotForInstrumentProperty:analyzer.trackedAmplitude withLabel:@"Amplitude"];
    [self addPlotForInstrumentProperty:analyzer.trackedFrequency withLabel:@"Frequency"];

//    [self addFFTView];
//    [self addRollingWaveformView];
    
}

@end

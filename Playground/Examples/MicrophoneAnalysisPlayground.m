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

- (instancetype)initWithNumber:(int)instrumentNumber
{
    self = [super initWithNumber:instrumentNumber];
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
    [self addAudioInputView];
    
    VocalInput *mic = [[VocalInput alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:mic.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    [analyzer play];
    [mic play];

//    [self addPropertyView:analyzer.trackedAmplitude];
//    [self addAudioInputView];
//    [self addAudioOutputView];
//    [self addFFTView];
//    [self addRollingWaveformView];
    
}

@end

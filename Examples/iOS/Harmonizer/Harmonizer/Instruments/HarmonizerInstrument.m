//
//  HarmonizerInstrument.m
//  Harmonizer
//
//  Created by Aurelius Prochazka on 7/6/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "HarmonizerInstrument.h"
#import "AKFoundation.h"

@implementation HarmonizerInstrument

- (instancetype)init {
    self = [super init];
    if (self) {
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        [self connect:microphone];
        
        AKFSignalFromMonoAudio *microphoneFFT;
        microphoneFFT = [[AKFSignalFromMonoAudio alloc] initWithAudioSource:microphone
                                                                    fftSize:akpi(2048)
                                                                    overlap:akpi(256)
                                                                 windowType:AKFSignalFromMonoAudioWindowTypeVonHann
                                                           windowFilterSize:akpi(2048)];
        [self connect:microphoneFFT];
        
        AKScaledFSignal *scaledFFT;
        scaledFFT = [[AKScaledFSignal alloc] initWithInput:microphoneFFT
                                            frequencyRatio:akp(2.0)
                                       formantRetainMethod:AKScaledFSignalFormantRetainMethodLifteredCepstrum
                                            amplitudeRatio:nil
                                      cepstrumCoefficients:nil];
        [self connect:scaledFFT];
        
        AKFSignalMix *mixedFFT = [[AKFSignalMix alloc] initWithInput1:microphoneFFT input2:scaledFFT];
        [self connect:mixedFFT];
        
        AKAudioFromFSignal *audioOutput = [[AKAudioFromFSignal alloc] initWithSource:mixedFFT];
        [self connect:audioOutput];
        
        
        // AUDIO OUTPUT ========================================================
        AKAudioOutput *output = [[AKAudioOutput alloc] initWithAudioSource:audioOutput];
        [self connect:output];
    }
    return self;
}

@end

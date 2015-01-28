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
        
        AKFFT *microphoneFFT;
        microphoneFFT = [[AKFFT alloc] initWithInput:microphone
                                             fftSize:akpi(2048)
                                             overlap:akpi(256)
                                          windowType:AKFFTWindowTypeVonHann
                                    windowFilterSize:akpi(2048)];
        [self connect:microphoneFFT];
        
        AKScaledFFT *scaledFFT;
        scaledFFT = [[AKScaledFFT alloc] initWithSignal:microphoneFFT
                                         frequencyRatio:akp(2.0)
                                    formantRetainMethod:AKScaledFFTFormantRetainMethodLifteredCepstrum
                                         amplitudeRatio:akp(2.0)
                                   cepstrumCoefficients:nil];
        [self connect:scaledFFT];
        
        AKMixedFFT *mixedFFT = [[AKMixedFFT alloc] initWithSignal1:microphoneFFT signal2:scaledFFT];
        [self connect:mixedFFT];
        
        AKResynthesizedAudio *audioOutput = [[AKResynthesizedAudio alloc] initWithSignal:mixedFFT];
        [self connect:audioOutput];
        
        
        // AUDIO OUTPUT ========================================================
        AKAudioOutput *output = [[AKAudioOutput alloc] initWithAudioSource:audioOutput];
        [self connect:output];
    }
    return self;
}

@end

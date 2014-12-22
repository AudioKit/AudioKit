//
//  HarmonizerInstrument.m
//  Harmonizer
//
//  Created by Aurelius Prochazka on 7/6/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "HarmonizerInstrument.h"
#import "AKFoundation.h"

@implementation HarmonizerInstrument

- (instancetype)init {
    self = [super init];
    if (self) {
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        [self connect:microphone];
                
        AKFSignalFromMonoAudio *fsig1;
        fsig1 = [[AKFSignalFromMonoAudio alloc] initWithAudioSource:microphone
                                                            fftSize:akpi(2048)
                                                            overlap:akpi(256)
                                                         windowType:AKFSignalFromMonoAudioWindowTypeVonHann
                                                   windowFilterSize:akpi(2048)];
        [self connect:fsig1];
        
        AKScaledFSignal *fsig2;
        fsig2 = [[AKScaledFSignal alloc] initWithInput:fsig1
                                        frequencyRatio:akp(2.0)
                                   formantRetainMethod:AKScaledFSignalFormantRetainMethodLifteredCepstrum
                                        amplitudeRatio:nil
                                  cepstrumCoefficients:nil];
        [self connect:fsig2];
        
        AKScaledFSignal *fsig3;
        fsig3 = [[AKScaledFSignal alloc] initWithInput:fsig1
                                        frequencyRatio:akp(2.0)
                                   formantRetainMethod:AKScaledFSignalFormantRetainMethodLifteredCepstrum
                                        amplitudeRatio:nil
                                  cepstrumCoefficients:nil];
        [self connect:fsig3];
        
        AKFSignalMix *fsig4;
        fsig4 = [[AKFSignalMix alloc] initWithInput1:fsig2 input2:fsig3];
        [self connect:fsig4];
        
        AKAudioFromFSignal *a1;
        a1 = [[AKAudioFromFSignal alloc] initWithSource:fsig4];
        [self connect:a1];
        
        
        // AUDIO OUTPUT ========================================================
        AKAudio *a2 = [a1 scaledBy:akp(3)];
        AKAudioOutput *out = [[AKAudioOutput alloc] initWithAudioSource:a2];
        [self connect:out];
    }
    return self;
}

@end

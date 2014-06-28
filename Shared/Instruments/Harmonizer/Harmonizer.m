//
//  Harmonizer.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
	
#import "Harmonizer.h"

@implementation Harmonizer

- (instancetype)init 
{
    self = [super init];
    if (self) { 
        // INPUTS AND CONTROLS =================================================
        _pitch = [[AKInstrumentProperty alloc] initWithValue:kPitchInit
                                                     minimumValue:kPitchMin
                                                     maximumValue:kPitchMax];
        _gain  = [[AKInstrumentProperty alloc] initWithValue:kGainInit
                                                     minimumValue:kGainMin
                                                     maximumValue:kGainMax];
        
        [self addProperty:_pitch];
        [self addProperty:_gain];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        [self connect:microphone];
        
        AKFSignalFromMonoAudio *fsig1;
        fsig1 = [[AKFSignalFromMonoAudio alloc] initWithAudioSource:microphone
                                                             fftSize:akpi(2048)
                                                             overlap:akpi(256)
                                                          windowType:kVonHannWindow
                                                    windowFilterSize:akpi(2048)];
        [self connect:fsig1];
        
        AKScaledFSignal *fsig2;
        fsig2 = [[AKScaledFSignal alloc] initWithInput:fsig1
                                         frequencyRatio:_pitch
                                    formantRetainMethod:kFormantRetainMethodLifteredCepstrum 
                                         amplitudeRatio:nil
                                   cepstrumCoefficients:nil];
        [self connect:fsig2];
        
        AKScaledFSignal *fsig3;
        fsig3 = [[AKScaledFSignal alloc] initWithInput:fsig1
                                         frequencyRatio:[_pitch scaledBy:akp(1.25)]
                                    formantRetainMethod:kFormantRetainMethodLifteredCepstrum 
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
        AKAudio *a2 = [AKAudio parameterWithFormat:@"%@ * %@", a1, _gain];
        AKAudioOutput *out = [[AKAudioOutput alloc] initWithAudioSource:a2];
        [self connect:out];
    }
    return self;
}

@end

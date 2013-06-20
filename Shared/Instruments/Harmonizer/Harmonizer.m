//
//  Harmonizer.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Harmonizer.h"

@implementation Harmonizer

- (id)init 
{
    self = [super init];
    if (self) { 
        // INPUTS AND CONTROLS =================================================
        _pitch = [[OCSInstrumentProperty alloc] initWithValue:kPitchInit
                                                     minValue:kPitchMin
                                                     maxValue:kPitchMax];
        _gain  = [[OCSInstrumentProperty alloc] initWithValue:kGainInit
                                                     minValue:kGainMin
                                                     maxValue:kGainMax];
        
        [self addProperty:_pitch];
        [self addProperty:_gain];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSAudioInput *microphone = [[OCSAudioInput alloc] init];
        [self connect:microphone];
        
        OCSFSignalFromMonoAudio *fsig1;
        fsig1 = [[OCSFSignalFromMonoAudio alloc] initWithAudioSource:microphone
                                                             fftSize:ocspi(2048)
                                                             overlap:ocspi(256)
                                                          windowType:kVonHannWindow
                                                    windowFilterSize:ocspi(2048)];
        [self connect:fsig1];
        
        OCSScaledFSignal *fsig2;
        fsig2 = [[OCSScaledFSignal alloc] initWithInput:fsig1
                                         frequencyRatio:_pitch
                                    formantRetainMethod:kFormantRetainMethodLifteredCepstrum 
                                         amplitudeRatio:nil
                                   cepstrumCoefficients:nil];
        [self connect:fsig2];
        
        OCSScaledFSignal *fsig3;
        fsig3 = [[OCSScaledFSignal alloc] initWithInput:fsig1
                                         frequencyRatio:[_pitch scaledBy:ocsp(1.25)]
                                    formantRetainMethod:kFormantRetainMethodLifteredCepstrum 
                                         amplitudeRatio:nil
                                   cepstrumCoefficients:nil];
        [self connect:fsig3];
      
        OCSFSignalMix *fsig4;
        fsig4 = [[OCSFSignalMix alloc] initWithInput1:fsig2 input2:fsig3];
        [self connect:fsig4];
        
        OCSAudioFromFSignal *a1;
        a1 = [[OCSAudioFromFSignal alloc] initWithSource:fsig4];
        [self connect:a1];
        

        // AUDIO OUTPUT ========================================================
        OCSAudio *a2 = [OCSAudio parameterWithFormat:@"%@ * %@", a1, _gain];
        OCSAudioOutput *out = [[OCSAudioOutput alloc] initWithAudioSource:a2];
        [self connect:out];
    }
    return self;
}

@end

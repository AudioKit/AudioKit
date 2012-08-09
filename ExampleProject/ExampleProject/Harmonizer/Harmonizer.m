//
//  Harmonizer.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Harmonizer.h"
#import "OCSAudioInput.h"
#import "OCSFSignalFromMonoAudio.h"
#import "OCSScaledFSignal.h"
#import "OCSFSignalMix.h"
#import "OCSAudioFromFSignal.h"
#import "OCSAudio.h"

@interface Harmonizer () {
    OCSInstrumentProperty *pitch;
    OCSInstrumentProperty *gain;
}
@end

@implementation Harmonizer

@synthesize pitch;
@synthesize gain;

- (id)init 
{
    self = [super init];
    if (self) { 
        // INPUTS AND CONTROLS =================================================
        pitch = [[OCSInstrumentProperty alloc] initWithValue:kPitchInit 
                                                    minValue:kPitchMin 
                                                    maxValue:kPitchMax];
        gain  = [[OCSInstrumentProperty alloc] initWithValue:kGainInit 
                                                    minValue:kGainMin 
                                                    maxValue:kGainMax];
        
        [self addProperty:pitch];
        [self addProperty:gain];         
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSAudioInput *audio = [[OCSAudioInput alloc] init];
        [self addOpcode:audio];
        
        OCSFSignalFromMonoAudio *fsig1;
        fsig1 = [[OCSFSignalFromMonoAudio alloc] initWithInput:[audio output]
                                                       fftSize:ocspi(2048) 
                                                       overlap:ocspi(256) 
                                                    windowType:kVonHannWindow
                                              windowFilterSize:ocspi(2048)];
        [self addOpcode:fsig1];
        
        OCSScaledFSignal *fsig2;
        fsig2 = [[OCSScaledFSignal alloc] initWithInput:[fsig1 output]
                                         frequencyRatio:[pitch control]
                                    formantRetainMethod:kFormantRetainMethodLifteredCepstrum 
                                         amplitudeRatio:nil
                                   cepstrumCoefficients:nil];
        [self addOpcode:fsig2];
        
        OCSScaledFSignal *fsig3;
        fsig3 = [[OCSScaledFSignal alloc] initWithInput:[fsig1 output]
                                         frequencyRatio:[[pitch control] scaledBy:1.25f]
                                    formantRetainMethod:kFormantRetainMethodLifteredCepstrum 
                                         amplitudeRatio:nil
                                   cepstrumCoefficients:nil];
        [self addOpcode:fsig3];
      
        OCSFSignalMix *fsig4;
        fsig4 = [[OCSFSignalMix alloc] initWithInput1:[fsig2 output] input2:[fsig3 output]];
        [self addOpcode:fsig4];
        
        OCSAudioFromFSignal *a1;
        a1 = [[OCSAudioFromFSignal alloc] initWithSource:[fsig4 output]];  
        [self addOpcode:a1];
        

        // AUDIO OUTPUT ========================================================
        OCSParameter *a2 = [OCSParameter parameterWithFormat:@"%@ * %@", a1, [gain output]];
        OCSAudio *out = [[OCSAudio alloc] initWithMonoInput:a2];
        [self addOpcode:out];
    }
    return self;
}

@end

//
//  ExpressionToneGenerator.m
//  AudioKit Example
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionToneGenerator.h"

@implementation ExpressionToneGenerator

- (instancetype)init
{
    self = [super init];
    if (self) {                  
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable * sineTable = [[AKSineTable alloc] init];
        [self addFTable:sineTable];
        
        AKSineTable * vibratoSine = [[AKSineTable alloc] init];
        [self addDynamicFTable:vibratoSine];
        
        AKOscillatingControl * vibratoOscillator;

        vibratoOscillator = [[AKOscillatingControl alloc] initWithFTable:vibratoSine
                                                                frequency:akp(6)
                                                                amplitude:akp(40)];
        [self connect:vibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        AKControl * vibrato = [AKControl parameterWithFormat:
                                     @"%d + (%g * %@)", 
                                     vibratoOffset, vibratoScale, vibratoOscillator];
        
        AKConstant * amplitudeOffset = akp(0.0);
        
        AKLine * amplitudeRamp = [[AKLine alloc] initFromValue:akp(0) 
                                                         toValue:akp(0.5)
                                                        duration:akp(3.0)];
        [self connect:amplitudeRamp];
        
        AKControl * totalAmplitude = [AKControl parameterWithFormat:
                                            @"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        AKOscillator * oscillator;
        oscillator = [[AKOscillator alloc]  initWithFTable:sineTable
                                                  frequency:vibrato
                                                  amplitude:totalAmplitude];
        [self connect:oscillator ];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:oscillator];
        [self connect:audio];
    }
    return self;
}

@end

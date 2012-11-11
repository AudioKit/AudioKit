//
//  ExpressionToneGenerator.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionToneGenerator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSOscillatingControl.h"
#import "OCSLine.h"
#import "OCSAudioOutput.h"

@implementation ExpressionToneGenerator

- (id)init
{
    self = [super init];
    if (self) {                  
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable * sineTable = [[OCSSineTable alloc] init];
        [self addFTable:sineTable];
        
        OCSSineTable * vibratoSine = [[OCSSineTable alloc] init];
        [self addDynamicFTable:vibratoSine];
        
        OCSOscillatingControl * vibratoOscillator;

        vibratoOscillator = [[OCSOscillatingControl alloc] initWithFTable:vibratoSine
                                                                frequency:ocsp(6)
                                                                amplitude:ocsp(40)];
        [self connect:vibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        OCSControl * vibrato = [OCSControl parameterWithFormat:
                                     @"%d + (%g * %@)", 
                                     vibratoOffset, vibratoScale, vibratoOscillator];
        
        OCSConstant * amplitudeOffset = ocsp(0.0);
        
        OCSLine * amplitudeRamp = [[OCSLine alloc] initFromValue:ocsp(0) 
                                                         toValue:ocsp(0.5)
                                                        duration:ocsp(3.0)];
        [self connect:amplitudeRamp];
        
        OCSControl * totalAmplitude = [OCSControl parameterWithFormat:
                                            @"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        OCSOscillator * oscillator;
        oscillator = [[OCSOscillator alloc]  initWithFTable:sineTable
                                                  frequency:vibrato
                                                  amplitude:totalAmplitude];
        [self connect:oscillator ];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:oscillator];
        [self connect:audio];
    }
    return self;
}

@end

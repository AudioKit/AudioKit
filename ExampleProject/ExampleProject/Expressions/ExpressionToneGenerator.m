//
//  ExpressionToneGenerator.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ExpressionToneGenerator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSLine.h"
#import "OCSAudio.h"

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
        
        OCSOscillator * vibratoOscillator; 

        vibratoOscillator = [[OCSOscillator alloc] initWithFTable:vibratoSine
                                                        frequency:ocsp(6)
                                                        amplitude:ocsp(40)];
        [vibratoOscillator setOutput:[vibratoOscillator control]];
        [self addOpcode:vibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        OCSControl * vibrato = [OCSControl parameterWithFormat:
                                     @"%d + (%g * %@)", 
                                     vibratoOffset, vibratoScale, vibratoOscillator];
        
        OCSConstant * amplitudeOffset = ocsp(0.0);
        
        OCSLine * amplitudeRamp = [[OCSLine alloc] initFromValue:ocsp(0) 
                                                         toValue:ocsp(0.5)
                                                        duration:ocsp(3.0)];
        [self addOpcode:amplitudeRamp];
        
        OCSControl * totalAmplitude = [OCSControl parameterWithFormat:
                                            @"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        OCSOscillator * oscillator;
        oscillator = [[OCSOscillator alloc]  initWithFTable:sineTable
                                                  frequency:vibrato
                                                  amplitude:totalAmplitude];
        [self addOpcode:oscillator ];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[oscillator output]]; 
        [self addOpcode:audio];
    }
    return self;
}

@end

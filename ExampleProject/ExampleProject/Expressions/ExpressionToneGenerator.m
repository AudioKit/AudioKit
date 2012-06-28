//
//  ExpressionToneGenerator.m
//  ExampleProject
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
        [self addFunctionTable:sineTable];
        
        OCSSineTable * vibratoSine = [[OCSSineTable alloc] init];
        [self addFunctionTable:vibratoSine];
        
        OCSOscillator * vibratoOscillator; 

        vibratoOscillator = [[OCSOscillator alloc] initWithFunctionTable:vibratoSine
                                                               frequency:ocsp(6)
                                                               amplitude:ocsp(40)];
        [vibratoOscillator setOutput:[vibratoOscillator control]];
        [self addOpcode:vibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        OCSParamControl * vibrato = [OCSParamControl paramWithFormat:
                                     @"%d + (%g * %@)", 
                                     vibratoOffset, vibratoScale, vibratoOscillator];
        
        OCSParamConstant * amplitudeOffset = ocsp(0.1);
        
        OCSLine * amplitudeRamp = [[OCSLine alloc] initFromValue:ocsp(0) 
                                                         ToValue:ocsp(0.2)
                                                        Duration:duration];
        [self addOpcode:amplitudeRamp];
        
        OCSParamControl * totalAmplitude = [OCSParamControl paramWithFormat:
                                            @"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        OCSOscillator * oscillator;
        oscillator = [[OCSOscillator alloc]  initWithFunctionTable:sineTable
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

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
#import "OCSOutputStereo.h"

@interface ExpressionToneGenerator () {
    OCSProperty *frequency;
}
@end

@implementation ExpressionToneGenerator

- (id)init
{
    self = [super init];
    if (self) {                  
        // INPUTS AND CONTROLS =================================================
        
        frequency  = [[OCSProperty alloc] init];
        [frequency  setOutput:[OCSParamControl paramWithString:@"Frequency"]]; 
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSineTable * sineTable = [[OCSSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        OCSSineTable * vibratoSine = [[OCSSineTable alloc] init];
        [self addFunctionTable:vibratoSine];
        
        OCSOscillator * myVibratoOscillator = [[OCSOscillator alloc] initWithAmplitude:ocsp(40)
                                                                             Frequency:ocsp(6)
                                                                         FunctionTable:vibratoSine];
        [myVibratoOscillator setOutput:[myVibratoOscillator control]];
        [self addOpcode:myVibratoOscillator];
        
        float vibratoScale = 2.0f;
        int vibratoOffset = 320;
        OCSParamControl * vibrato = [OCSParamControl paramWithFormat:
                                     @"%d + (%f * %@)", 
                                     vibratoOffset, vibratoScale, myVibratoOscillator];
        
        OCSParamConstant * amplitudeOffset = ocsp(0.1);
        
        OCSLine * amplitudeRamp = [[OCSLine alloc] initFromValue:ocsp(0) 
                                                         ToValue:ocsp(0.2)
                                                        Duration:duration];
        [self addOpcode:amplitudeRamp];
        
        OCSParamControl * totalAmplitude = [OCSParamControl paramWithFormat:
                                            @"%@ + %@", amplitudeRamp, amplitudeOffset];                    
        OCSOscillator * myOscillator = [[OCSOscillator alloc]  initWithAmplitude:totalAmplitude
                                                                       Frequency:vibrato
                                                                   FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo * stereoOutput = [[OCSOutputStereo alloc] initWithMonoInput:[myOscillator output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}
- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}

@end

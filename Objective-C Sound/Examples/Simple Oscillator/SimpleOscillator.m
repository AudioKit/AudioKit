//
//  SimpleOscillator.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleOscillator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSReverb.h"
#import "OCSAudio.h"

@implementation SimpleOscillator

@synthesize frequency;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequency = [[OCSNoteProperty alloc] initWithMinValue:kFrequencyMin maxValue:kFrequencyMax];
        [frequency setConstant:[OCSConstant parameterWithString:@"Frequency"]]; 
        [self addNoteProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSParameterArray *partialStrengthParamArray = 
        [OCSParameterArray paramArrayFromParams: ocsp(1),ocsp(0.5), ocsp(1), nil];
        
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096 
                                 partialStrengths:partialStrengthParamArray];
        [self addFTable:sine];
        
        OCSOscillator *myOscil;
        myOscil = [[OCSOscillator alloc] initWithFTable:sine
                                              frequency:[frequency constant]
                                              amplitude:ocsp(0.12)];                                
        [self addOpcode:myOscil];
        
        OCSReverb *reverb;
        reverb = [[OCSReverb alloc] initWithLeftInput:[myOscil output] 
                                           rightInput:[myOscil output] 
                                        feedbackLevel:ocsp(0.85)
                                      cutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio;
        audio = [[OCSAudio alloc] initWithLeftInput:[reverb leftOutput] 
                                         rightInput:[reverb rightOutput]]; 
        [self addOpcode:audio];
    }
    return self;
}

@end

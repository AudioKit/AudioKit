//
//  SoundGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SoundGenerator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSReverb.h"
#import "OCSAudio.h"

@interface SoundGenerator () {
    OCSProperty *freq;
}
@end

@implementation SoundGenerator

@synthesize frequency = freq;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        freq = [[OCSProperty alloc] initWithMinValue:kFrequencyMin maxValue:kFrequencyMax];
        [freq setConstant:[OCSConstantParam paramWithString:@"Frequency"]]; 
        [self addProperty:freq];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSParamArray *partialStrengthParamArray = 
        [OCSParamArray paramArrayFromParams: ocsp(1),ocsp(0.5), ocsp(1), nil];
        
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096 
                                 partialStrengths:partialStrengthParamArray];
        [self addFTable:sine];
        
        OCSOscillator *myOscil;
        myOscil = [[OCSOscillator alloc] initWithFTable:sine
                                              frequency:[freq constant]
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
        audio = [[OCSAudio alloc] initWithLeftInput:[reverb outputLeft] 
                                         rightInput:[reverb outputRight]]; 
        [self addOpcode:audio];
    }
    return self;
}

- (void)playNoteForDuration:(float)noteDuration 
                  frequency:(float)frequency;
{
    freq.value = frequency;
    NSLog(@"Playing note at frequency = %0.2f", frequency);
    [self playNoteForDuration:noteDuration];
}

@end

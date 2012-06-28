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
    OCSProperty *frequency;
}
@end

@implementation SoundGenerator

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequency = [[OCSProperty alloc] init];
        [frequency setConstant:[OCSParamConstant paramWithString:@"Frequency"]]; 
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSParamArray *partialStrengthParamArray = 
        [OCSParamArray paramArrayFromParams: ocsp(1),ocsp(0.5), ocsp(1), nil];
        
        OCSSineTable *sine;
        sine = [[OCSSineTable alloc] initWithSize:4096 
                                 partialStrengths:partialStrengthParamArray];
        [self addFunctionTable:sine];
        
        OCSOscillator *myOscil;
        myOscil = [[OCSOscillator alloc] initWithFunctionTable:sine
                                                     frequency:[frequency constant]
                                                     amplitude:ocsp(0.12)];                                
        [self addOpcode:myOscil];
        
        OCSReverb *reverb;
        reverb = [[OCSReverb alloc] initWithLeftInput:[myOscil output] 
                                           RightInput:[myOscil output] 
                                        FeedbackLevel:ocsp(0.85)
                                      CutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio;
        audio = [[OCSAudio alloc] initWithLeftInput:[reverb outputLeft] 
                                         RightInput:[reverb outputRight]]; 
        [self addOpcode:audio];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    NSLog(@"Playing note at frequency = %0.2f", freq);
    [self playNoteForDuration:dur];
}

@end

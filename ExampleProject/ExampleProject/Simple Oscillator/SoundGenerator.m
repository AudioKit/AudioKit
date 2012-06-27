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
        
        OCSSineTable *sineTable = [[OCSSineTable alloc] initWithSize:4096 
                                                     PartialStrengths:partialStrengthParamArray];
        [self addFunctionTable:sineTable];
        
        OCSOscillator *myOscillator = [[OCSOscillator alloc] initWithFunctionTable:sineTable
                                                                         Amplitude:ocsp(0.12)
                                                                         Frequency:[frequency constant]];                                
        [self addOpcode:myOscillator];
        
        OCSReverb *reverb = [[OCSReverb alloc] initWithLeftInput:[myOscillator output] 
                                                      RightInput:[myOscillator output] 
                                                   FeedbackLevel:ocsp(0.85)
                                                 CutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[reverb outputLeft] 
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

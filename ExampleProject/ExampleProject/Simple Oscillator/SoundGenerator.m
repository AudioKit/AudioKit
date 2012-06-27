//
//  SoundGenerator.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  NOTE: Alternate sineTable definition:
//  float partialStrengths[] = {1.0f, 0.5f, 1.0f};
//  OCSParamArray *partialStrengthParamArray = [OCSParamArray paramArrayFromFloats:partialStrengths count:3];

#import "SoundGenerator.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSReverb.h"
#import "OCSOutputStereo.h"

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
        
        OCSOscillator *myOscillator = [[OCSOscillator alloc] initWithAmplitude:ocsp(0.12)
                                                                      Frequency:[frequency constant]
                                                                  FunctionTable:sineTable];
        [self addOpcode:myOscillator];
        
        OCSReverb *reverb = [[OCSReverb alloc] initWithInputLeft:[myOscillator output] 
                                                       InputRight:[myOscillator output] 
                                                    FeedbackLevel:ocsp(0.85)
                                                  CutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo *stereoOutput = [[OCSOutputStereo alloc] initWithLeftInput:[reverb outputLeft] 
                                                                        RightInput:[reverb outputRight]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    NSLog(@"Playing note at frequency = %0.2f", freq);
    [self playNoteForDuration:dur];
}

@end

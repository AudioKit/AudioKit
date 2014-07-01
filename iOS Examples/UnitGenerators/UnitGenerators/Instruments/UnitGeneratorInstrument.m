//
//  UnitGeneratorInstrument.m
//  UnitGenerators
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "UnitGeneratorInstrument.h"
#import "AKFoundation.h"

@implementation UnitGeneratorInstrument


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT DEFINITION ===============================================
        // create sine function with variable partial strengths
        
        AKArray *partialStrengths = akpna(@1, @0.5, @1, nil);
        
        AKSineTable *sine;
        sine = [[AKSineTable alloc] initWithSize:4096
                                partialStrengths:partialStrengths];
        [sine setIsNormalized:YES];
        [self addFTable:sine];
        
        AKLine *myLine = [[AKLine alloc] initFromValue:akp(0.5)
                                               toValue:akp(1.5)
                                              duration:akp(3.0)];
        [self connect:myLine];
        
        //Init LineSegment_a, without AKArray Functions like line
        AKLinearControl *baseFrequencyLine;
        baseFrequencyLine = [[AKLinearControl alloc] initFromValue:akp(110)
                                                           toValue:akp(330)
                                                          duration:akp(3.0)];
        [self connect:baseFrequencyLine];
        
        AKControlSegmentArray *modIndexLine;
        modIndexLine = [[AKControlSegmentArray alloc] initWithStartValue:akp(0.5)
                                                             toNextValue:akp(0.2)
                                                           afterDuration:akp(3)];
        [modIndexLine addValue:akp(1.5) afterDuration:akp(3)];
        [modIndexLine addValue:akp(0.5) afterDuration:akp(3)];
        [self connect:modIndexLine];
        
        // create fmOscillator with sine, lines for pitch, modulation, and modindex
        AKFMOscillator *fmOscil;
        fmOscil = [[AKFMOscillator alloc] initWithFTable:sine
                                           baseFrequency:baseFrequencyLine
                                       carrierMultiplier:akp(1)
                                    modulatingMultiplier:myLine
                                         modulationIndex:modIndexLine
                                               amplitude:akp(0.4)];
        [self connect:fmOscil];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:fmOscil];
        [self connect:audio];
    }
    return self;
}


@end

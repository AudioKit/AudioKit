//
//  GranularInstrument.m
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "GranularInstrument.h"
#import "AKFoundation.h"

@implementation GranularInstrument

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // INPUTS AND CONTROLS =================================================
        _averageGrainDuration   = [[AKInstrumentProperty alloc] initWithValue:0.05
                                                                      minimum:0.001
                                                                      maximum:0.05];
        
        _grainDensity   = [[AKInstrumentProperty alloc] initWithValue:25
                                                              minimum:0
                                                              maximum:2000];
        
        
        _granularFrequencyDeviation   = [[AKInstrumentProperty alloc] initWithValue:1500
                                                                            minimum:1
                                                                            maximum:3000];
        
        
        _granularAmplitude   = [[AKInstrumentProperty alloc] initWithValue:1
                                                                   minimum:0
                                                                   maximum:2];
        
        [self addProperty:_averageGrainDuration];
        [self addProperty:_grainDensity];
        [self addProperty:_granularFrequencyDeviation];
        [self addProperty:_granularAmplitude];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"PianoBassDrumLoop"
                                                         ofType:@"wav"];
        AKSoundFileTable *fileTable;
        fileTable = [[AKSoundFileTable alloc] initWithFilename:file
                                                     tableSize:16384];
        [self addFTable:fileTable];
        
        AKFTable *hamming;
        hamming = [[AKWindowsTable alloc] initWithType:kWindowHanning
                                                  size:512 ];
        [self addFTable:hamming];
        
        AKConstant *baseFrequency;
        NSString *frequencyMathString = [NSString stringWithFormat:@"44100 / %@", [fileTable length]];
        baseFrequency = [[AKConstant alloc] initWithExpression:frequencyMathString];
        
        AKGranularSynthesisTexture *grainTexture;
        grainTexture = [[AKGranularSynthesisTexture alloc] initWithGrainFTable:fileTable
                                                                  windowFTable:hamming
                                                          maximumGrainDuration:akp(0.05)
                                                          averageGrainDuration:_averageGrainDuration
                                                     maximumFrequencyDeviation:_granularFrequencyDeviation
                                                                grainFrequency:baseFrequency
                                                     maximumAmplitudeDeviation:akp(0.5)
                                                                grainAmplitude:_granularAmplitude
                                                                  grainDensity:_grainDensity];
        [self connect:grainTexture];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:(grainTexture)];
        [self connect:audio];
    }
    return self;
}

@end

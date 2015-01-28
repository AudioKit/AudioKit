//
//  GranularInstrument.m
//  GranularSynthTest
//
//  Created by Nicholas Arner on 9/2/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
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
        _averageGrainDuration       = [[AKInstrumentProperty alloc] initWithValue:0.25 minimum:0.1  maximum:0.4];
        _grainDensity               = [[AKInstrumentProperty alloc] initWithValue:300  minimum:10   maximum:600];
        _granularFrequencyDeviation = [[AKInstrumentProperty alloc] initWithValue:0.05 minimum:0    maximum:0.1];
        _granularAmplitude          = [[AKInstrumentProperty alloc] initWithValue:0.1  minimum:0.01 maximum:0.2];
        
        [self addProperty:_averageGrainDuration];
        [self addProperty:_grainDensity];
        [self addProperty:_granularFrequencyDeviation];
        [self addProperty:_granularAmplitude];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"PianoBassDrumLoop"
                                                         ofType:@"wav"];
        AKSoundFile *fileTable;
        fileTable = [[AKSoundFile alloc] initWithFilename:file];
        fileTable.size = 16384;
        [self addFunctionTable:fileTable];
        
        AKFunctionTable *hamming;
        hamming = [[AKWindow alloc] initWithType:AKWindowTableTypeHamming];
        hamming.size = 512;
        [self addFunctionTable:hamming];
        
        AKConstant *baseFrequency;
        NSString *frequencyMathString = [NSString stringWithFormat:@"44100 / %@", [fileTable length]];
        baseFrequency = [[AKConstant alloc] initWithExpression:frequencyMathString];
        
        AKGranularSynthesisTexture *grainTexture;
        grainTexture = [AKGranularSynthesisTexture textureWithGrainFunctionTable:fileTable
                                                             windowFunctionTable:hamming];
        grainTexture.averageGrainDuration = _averageGrainDuration;
        grainTexture.maximumFrequencyDeviation = _granularFrequencyDeviation;
        grainTexture.grainFrequency = baseFrequency;
        grainTexture.grainAmplitude = _granularAmplitude;
        grainTexture.grainDensity = _grainDensity;
        
        [self connect:grainTexture];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:grainTexture];
        [self connect:audio];
    }
    return self;
}

@end

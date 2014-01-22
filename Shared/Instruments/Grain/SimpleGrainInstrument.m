//
//  SimpleGrainInstrument.m
//  AudioKit Example
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleGrainInstrument.h"

@implementation SimpleGrainInstrument

- (instancetype)init 
{
    self = [super init];
    if (self) { 
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"beats" 
                                                         ofType:@"wav"];
        AKSoundFileTable *fileTable;
        fileTable = [[AKSoundFileTable alloc] initWithFilename:file 
                                                      tableSize:16384];
        [self addFTable:fileTable];
        
        AKFTable *hamming;
        hamming = [[AKWindowsTable alloc] initWithType:kWindowHanning
                                                   size:512 ];
        [self addFTable:hamming];
                
        AKAudioSegmentArray *amplitudeExp;
        amplitudeExp = [[AKAudioSegmentArray alloc] initWithStartValue:akp(0.001)
                                                            toNextValue:akp(0.1)
                                                          afterDuration:akp(4.5)];
        [amplitudeExp addValue:akp(0.01) afterDuration:akp(4.5)];
        [amplitudeExp useExponentialSegments];
        [self connect:amplitudeExp];

        AKConstant *baseFrequency;
        baseFrequency = [AKConstant parameterWithFormat:@"44100 / %@", [fileTable length]];
        AKLine *pitchLine;
        pitchLine = [[AKLine alloc] initFromValue:baseFrequency
                                           toValue:[baseFrequency scaledBy:akp(0.8)]
                                          duration:akp(9.0)];
        [self connect:pitchLine];
        
        AKLine *grainDensityLine = [[AKLine alloc] initFromValue:akp(600)
                                                           toValue:akp(300)
                                                          duration:akp(9.0)];
        [self connect:grainDensityLine];
        
        AKLinearControl *ampOffsetLine;
        ampOffsetLine = [[AKLinearControl alloc] initFromValue:akp(0)
                                                        toValue:akp(0.1)
                                                       duration:akp(9.0)];
        [self connect:ampOffsetLine];
        
        AKLinearControl *pitchOffsetLine;
        pitchOffsetLine = [[AKLinearControl alloc] initFromValue:akp(0)
                                                          toValue:[baseFrequency scaledBy:akp(0.5)]
                                                         duration:akp(9.0) ];
        [self connect:pitchOffsetLine];
        
        
        AKLinearControl *grainDurationLine;
        grainDurationLine = [[AKLinearControl alloc] initFromValue:akp(0.1)
                                                            toValue:akp(0.1)
                                                           duration:akp(9.0)];
        [self connect:grainDurationLine];
        
        AKGrain *grainL;
        grainL = [[AKGrain alloc] initWithGrainFunction:fileTable  
                                          windowFunction:hamming 
                                        maxGrainDuration:akp(5) 
                                               amplitude:amplitudeExp
                                          grainFrequency:pitchLine
                                            grainDensity:grainDensityLine
                                           grainDuration:grainDurationLine
                                   maxAmplitudeDeviation:ampOffsetLine
                                       maxPitchDeviation:pitchOffsetLine];
        [self connect:grainL];
        
        AKGrain *grainR;
        grainR = [[AKGrain alloc] initWithGrainFunction:fileTable  
                                          windowFunction:hamming 
                                        maxGrainDuration:akp(6) 
                                               amplitude:amplitudeExp
                                          grainFrequency:pitchLine
                                            grainDensity:grainDensityLine
                                           grainDuration:grainDurationLine
                                   maxAmplitudeDeviation:ampOffsetLine
                                       maxPitchDeviation:pitchOffsetLine];
        [self connect:grainR];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithLeftAudio:grainL
                                                               rightAudio:grainR];
        [self connect:audio];
    }
    return self;
}


@end

//
//  GrainInstrument.m
//  Grain
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "GrainInstrument.h"
#import "AKFoundation.h"

@implementation GrainInstrument

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
        
        AKGranularSynthesisTexture *grainL;
        grainL = [[AKGranularSynthesisTexture alloc] initWithGrainFTable:fileTable
                                                            windowFTable:hamming
                                                    maximumGrainDuration:akp(5)
                                                    averageGrainDuration:grainDurationLine
                                               maximumFrequencyDeviation:pitchOffsetLine
                                                          grainFrequency:pitchLine
                                               maximumAmplitudeDeviation:ampOffsetLine
                                                          grainAmplitude:amplitudeExp
                                                            grainDensity:grainDensityLine];
        [self connect:grainL];
        
        AKGranularSynthesisTexture *grainR;
        grainR = [[AKGranularSynthesisTexture alloc] initWithGrainFTable:fileTable
                                                            windowFTable:hamming
                                                    maximumGrainDuration:akp(6)
                                                    averageGrainDuration:grainDurationLine
                                               maximumFrequencyDeviation:pitchOffsetLine
                                                          grainFrequency:pitchLine
                                               maximumAmplitudeDeviation:ampOffsetLine
                                                          grainAmplitude:amplitudeExp
                                                            grainDensity:grainDensityLine];
        [self connect:grainR];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithLeftAudio:grainL
                                                             rightAudio:grainR];
        [self connect:audio];
    }
    return self;
}

@end

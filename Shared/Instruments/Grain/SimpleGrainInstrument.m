//
//  SimpleGrainInstrument.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleGrainInstrument.h"
#import "OCSSoundFileTable.h"
#import "OCSWindowsTable.h"
#import "OCSLine.h"
#import "OCSLinearControl.h"
#import "OCSAudioSegmentArray.h"
#import "OCSGrain.h"
#import "OCSAudioOutput.h"

@implementation SimpleGrainInstrument

- (id)init 
{
    self = [super init];
    if (self) { 
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file = [[NSBundle mainBundle] pathForResource:@"beats" 
                                                         ofType:@"wav"];
        OCSSoundFileTable *fileTable;
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file 
                                                      tableSize:16384];
        [self addFTable:fileTable];
        
        OCSFTable *hamming;
        hamming = [[OCSWindowsTable alloc] initWithType:kWindowHanning
                                                   size:512 ];
        [self addFTable:hamming];
                
        OCSAudioSegmentArray *amplitudeExp;
        amplitudeExp = [[OCSAudioSegmentArray alloc] initWithStartValue:ocsp(0.001)
                                                            toNextValue:ocsp(0.1)
                                                          afterDuration:ocsp(4.5)];
        [amplitudeExp addValue:ocsp(0.01) afterDuration:ocsp(4.5)];
        [amplitudeExp useExponentialSegments];
        [self connect:amplitudeExp];

        OCSConstant *baseFrequency;
        baseFrequency = [OCSConstant parameterWithFormat:@"44100 / %@", [fileTable length]];
        OCSLine *pitchLine;
        pitchLine = [[OCSLine alloc] initFromValue:baseFrequency
                                           toValue:[baseFrequency scaledBy:0.8]
                                          duration:ocsp(9.0)];
        [self connect:pitchLine];
        
        OCSLine *grainDensityLine = [[OCSLine alloc] initFromValue:ocsp(600)
                                                           toValue:ocsp(300)
                                                          duration:ocsp(9.0)];
        [self connect:grainDensityLine];
        
        OCSLinearControl *ampOffsetLine;
        ampOffsetLine = [[OCSLinearControl alloc] initFromValue:ocsp(0)
                                                        toValue:ocsp(0.1)
                                                       duration:ocsp(9.0)];
        [self connect:ampOffsetLine];
        
        OCSLinearControl *pitchOffsetLine;
        pitchOffsetLine = [[OCSLinearControl alloc] initFromValue:ocsp(0)
                                                          toValue:[baseFrequency scaledBy:0.5]
                                                         duration:ocsp(9.0) ];
        [self connect:pitchOffsetLine];
        
        
        OCSLinearControl *grainDurationLine;
        grainDurationLine = [[OCSLinearControl alloc] initFromValue:ocsp(0.1)
                                                            toValue:ocsp(0.1)
                                                           duration:ocsp(9.0)];
        [self connect:grainDurationLine];
        
        OCSGrain *grainL;
        grainL = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                          windowFunction:hamming 
                                        maxGrainDuration:ocsp(5) 
                                               amplitude:amplitudeExp
                                          grainFrequency:pitchLine
                                            grainDensity:grainDensityLine
                                           grainDuration:grainDurationLine
                                   maxAmplitudeDeviation:ampOffsetLine
                                       maxPitchDeviation:pitchOffsetLine];
        [self connect:grainL];
        
        OCSGrain *grainR;
        grainR = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                          windowFunction:hamming 
                                        maxGrainDuration:ocsp(6) 
                                               amplitude:amplitudeExp
                                          grainFrequency:pitchLine
                                            grainDensity:grainDensityLine
                                           grainDuration:grainDurationLine
                                   maxAmplitudeDeviation:ampOffsetLine
                                       maxPitchDeviation:pitchOffsetLine];
        [self connect:grainR];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithLeftInput:grainL
                                                               rightInput:grainR];
        [self connect:audio];
    }
    return self;
}


@end

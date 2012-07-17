//
//  SimpleGrainInstrument.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleGrainInstrument.h"
#import "OCSSoundFileTable.h"
#import "OCSWindowsTable.h"
#import "OCSLine.h"
#import "OCSSegmentArray.h"
#import "OCSProperty.h"
#import "OCSGrain.h"
#import "OCSAudio.h"

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
                
        OCSSegmentArray *amplitudeExp;
        amplitudeExp = [[OCSSegmentArray alloc] initWithStartValue:ocsp(0.001)  
                                                       toNextValue:ocsp(0.1)  
                                                     afterDuration:ocsp(4.5)];
        [amplitudeExp addValue:ocsp(0.01) afterDuration:ocsp(4.5)];
        [amplitudeExp useExponentialSegments];
        [self addOpcode:amplitudeExp];

        OCSConstant *baseFrequency;
        baseFrequency = [OCSConstant parameterWithFormat:@"44100 / %@", [fileTable length]];
        OCSLine *pitchLine;
        pitchLine = [[OCSLine alloc] initFromValue:baseFrequency
                                           toValue:[baseFrequency scaledBy:0.8]
                                          duration:ocsp(9.0)];
        [self addOpcode:pitchLine];
        
        OCSLine *grainDensityLine = [[OCSLine alloc] initFromValue:ocsp(600)
                                                           toValue:ocsp(300)
                                                          duration:ocsp(9.0)];
        [self addOpcode:grainDensityLine];
        
        OCSLine *ampOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                        toValue:ocsp(0.1)
                                                       duration:ocsp(9.0)];
        [ampOffsetLine setOutput:[ampOffsetLine control]];
        [self addOpcode:ampOffsetLine];
        
        OCSLine *pitchOffsetLine;
        pitchOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                 toValue:[baseFrequency scaledBy:0.5]
                                                duration:ocsp(9.0) ];
        [pitchOffsetLine setOutput:[pitchOffsetLine control]];
        [self addOpcode:pitchOffsetLine];   
        
        
        OCSLine *grainDurationLine = [[OCSLine alloc] initFromValue:ocsp(0.1)
                                                            toValue:ocsp(0.1)
                                                           duration:ocsp(9.0)];
        [grainDurationLine setOutput:[grainDurationLine control]];
        [self addOpcode:grainDurationLine];
        
        OCSGrain *grainL;
        grainL = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                          windowFunction:hamming 
                                        maxGrainDuration:ocsp(5) 
                                               amplitude:[amplitudeExp output] 
                                          grainFrequency:[pitchLine output] 
                                            grainDensity:[grainDensityLine output] 
                                           grainDuration:[grainDurationLine control] 
                                   maxAmplitudeDeviation:[ampOffsetLine control] 
                                       maxPitchDeviation:[pitchOffsetLine control] ];
        [self addOpcode:grainL];
        
        OCSGrain *grainR;
        grainR = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                          windowFunction:hamming 
                                        maxGrainDuration:ocsp(6) 
                                               amplitude:[amplitudeExp output] 
                                          grainFrequency:[pitchLine output] 
                                            grainDensity:[grainDensityLine output] 
                                           grainDuration:[grainDurationLine control] 
                                   maxAmplitudeDeviation:[ampOffsetLine control] 
                                       maxPitchDeviation:[pitchOffsetLine control] ];
        [self addOpcode:grainR];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[grainL output] 
                                                   rightInput:[grainR output]]; 
        [self addOpcode:audio];
    }
    return self;
}


@end

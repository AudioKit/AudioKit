//
//  SimpleGrainInstrument.m
//  ExampleProject
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
        [self addFunctionTable:fileTable];
        
        OCSFunctionTable *hamming;
        hamming = [[OCSWindowsTable alloc] initWithType:kWindowHanning
                                                   size:512 ];
        [self addFunctionTable:hamming];
                
        OCSSegmentArray *amplitudeExp;
        amplitudeExp = [[OCSSegmentArray alloc] initWithStartValue:ocsp(0.001)  
                                                       toNextValue:ocsp(0.1)  
                                                     afterDuration:[duration scaledBy:0.5]];
        [amplitudeExp addValue:ocsp(0.01) afterDuration:[duration scaledBy:0.5]];
        [amplitudeExp useExponentialSegments];
        [self addOpcode:amplitudeExp];

        OCSParamConstant *baseFrequency;
        baseFrequency = [OCSParamConstant paramWithFormat:@"44100 / %@", [fileTable length]];
        OCSLine *pitchLine;
        pitchLine = [[OCSLine alloc] initFromValue:baseFrequency
                                           toValue:[baseFrequency scaledBy:0.8]
                                          duration:duration];
        [self addOpcode:pitchLine];
        
        OCSLine *grainDensityLine = [[OCSLine alloc] initFromValue:ocsp(600)
                                                           toValue:ocsp(300)
                                                          duration:duration];
        [self addOpcode:grainDensityLine];
        
        OCSLine *ampOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                        toValue:ocsp(0.1)
                                                       duration:duration];
        [ampOffsetLine setOutput:[ampOffsetLine control]];
        [self addOpcode:ampOffsetLine];
        
        OCSLine *pitchOffsetLine;
        pitchOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                 toValue:[baseFrequency scaledBy:0.5]
                                                duration:duration ];
        [pitchOffsetLine setOutput:[pitchOffsetLine control]];
        [self addOpcode:pitchOffsetLine];   
        
        
        OCSLine *grainDurationLine = [[OCSLine alloc] initFromValue:ocsp(0.1)
                                                            toValue:ocsp(0.1)
                                                           duration:duration];
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

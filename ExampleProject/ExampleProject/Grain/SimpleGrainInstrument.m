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
        hamming = [[OCSWindowsTable alloc] initWithSize:512 
                                             windowType:kWindowHanning];
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
                                           ToValue:[baseFrequency scaledBy:0.8]
                                          Duration:duration];
        [self addOpcode:pitchLine];
        
        OCSLine *grainDensityLine = [[OCSLine alloc] initFromValue:ocsp(600)
                                                           ToValue:ocsp(300)
                                                          Duration:duration];
        [self addOpcode:grainDensityLine];
        
        OCSLine *ampOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                        ToValue:ocsp(0.1)
                                                       Duration:duration];
        [ampOffsetLine setOutput:[ampOffsetLine control]];
        [self addOpcode:ampOffsetLine];
        
        OCSLine *pitchOffsetLine;
        pitchOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                 ToValue:[baseFrequency scaledBy:0.5]
                                                Duration:duration ];
        [pitchOffsetLine setOutput:[pitchOffsetLine control]];
        [self addOpcode:pitchOffsetLine];   
        
        
        OCSLine *grainDurationLine = [[OCSLine alloc] initFromValue:ocsp(0.1)
                                                            ToValue:ocsp(0.1)
                                                           Duration:duration];
        [grainDurationLine setOutput:[grainDurationLine control]];
        [self addOpcode:grainDurationLine];
        
        OCSGrain *grainL;
        grainL = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                          WindowFunction:hamming 
                                        MaxGrainDuration:ocsp(5) 
                                               Amplitude:[amplitudeExp output] 
                                              GrainPitch:[pitchLine output] 
                                            GrainDensity:[grainDensityLine output] 
                                           GrainDuration:[grainDurationLine control] 
                                   MaxAmplitudeDeviation:[ampOffsetLine control] 
                                       MaxPitchDeviation:[pitchOffsetLine control] ];
        [self addOpcode:grainL];
        
        OCSGrain *grainR;
        grainR = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                          WindowFunction:hamming 
                                        MaxGrainDuration:ocsp(6) 
                                               Amplitude:[amplitudeExp output] 
                                              GrainPitch:[pitchLine output] 
                                            GrainDensity:[grainDensityLine output] 
                                           GrainDuration:[grainDurationLine control] 
                                   MaxAmplitudeDeviation:[ampOffsetLine control] 
                                       MaxPitchDeviation:[pitchOffsetLine control] ];
        [self addOpcode:grainR];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[grainL output] 
                                                   RightInput:[grainR output]]; 
        [self addOpcode:audio];
    }
    return self;
}


@end

//
//  SimpleGrainInstrument.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleGrainInstrument.h"

@implementation SimpleGrainInstrument

- (id)initWithOrchestra:(OCSOrchestra *)orch
{
    self = [super initWithOrchestra:orch];
    if (self) { 
        // INSTRUMENT DEFINITION ===============================================
        NSString * file = [[NSBundle mainBundle] pathForResource:@"beats" 
                                                          ofType:@"wav"];
        OCSSoundFileTable *fileTable = 
        [[OCSSoundFileTable alloc] initWithFilename:file TableSize:16384];
        [self addFunctionTable:fileTable];
        
        
        OCSFunctionTable *hamming = 
        [[OCSWindowsTable alloc] initWithSize:512 
                                   WindowType:kWindowHanning];
        [self addFunctionTable:hamming];
        
        OCSFileLength *fileLength = [[OCSFileLength alloc] initWithInput:fileTable];
        [self addOpcode:fileLength];
        
        OCSParamArray *amplitudeSegmentArray = 
        [OCSParamArray paramArrayFromParams:
         [OCSParamConstant paramWithFormat:@"%@ / 2", duration], ocsp(0.01), nil];
        
        OCSParamConstant *halfDuration = 
        [OCSParamConstant paramWithFormat:@"%@ / 2", duration];
        
        OCSExpSegment *amplitudeExp = 
        [[OCSExpSegment alloc] initWithFirstSegmentStartValue:ocsp(0.001) 
                                         FirstSegmentDuration:halfDuration
                                     FirstSegementTargetValue:ocsp(0.1)
                                                 SegmentArray:amplitudeSegmentArray];
        [self addOpcode:amplitudeExp];
        
        
        OCSParamConstant *baseFrequency = 
        [OCSParamConstant paramWithFormat:@"44100 / %@", fileLength];
        OCSParamConstant *finalFrequency = 
        [OCSParamConstant paramWithFormat:@"0.8 * (%@)", baseFrequency];
        OCSLine * pitchLine = 
        [[OCSLine alloc] initWithStartingValue:baseFrequency
                                      Duration:duration 
                                   TargetValue:finalFrequency];
        [self addOpcode:pitchLine];
        
        OCSLine *grainDensityLine = 
        [[OCSLine alloc] initWithStartingValue:ocsp(600)
                                      Duration:duration 
                                   TargetValue:ocsp(300)];
        [self addOpcode:grainDensityLine];
        
        OCSLine *ampOffsetLine = 
        [[OCSLine alloc] initWithStartingValue:ocsp(0)
                                      Duration:duration 
                                   TargetValue:ocsp(0.1)];
        [self addOpcode:ampOffsetLine];
        
        
        OCSParamConstant *finalPitchOffset =
        [OCSParamConstant paramWithFormat:@"0.5 * (%@)", baseFrequency];
        OCSLine *pitchOffsetLine = 
        [[OCSLine alloc] initWithStartingValue:ocsp(0)
                                      Duration:duration 
                                   TargetValue:finalPitchOffset];
        [self addOpcode:pitchOffsetLine];   
        
        OCSLine *grainDurationLine = 
        [[OCSLine alloc] initWithStartingValue:ocsp(0.1)
                                      Duration:duration 
                                   TargetValue:ocsp(0.1)];
        [self addOpcode:grainDurationLine];
        
        OCSGrain * grainL = 
        [[OCSGrain alloc] initWithAmplitude:[amplitudeExp output] 
                                      Pitch:[pitchLine output]
                               GrainDensity:[grainDensityLine output]
                            AmplitudeOffset:[ampOffsetLine output]
                                PitchOffset:[pitchOffsetLine output] 
                              GrainDuration:[grainDurationLine output]  
                           MaxGrainDuration:ocsp(5)
                              GrainFunction:fileTable 
                             WindowFunction:hamming 
                 IsRandomGrainFunctionIndex:NO];
        [self addOpcode:grainL];
        
        OCSGrain *grainR = 
        [[OCSGrain alloc] initWithAmplitude:[amplitudeExp output] 
                                      Pitch:[pitchLine output]
                               GrainDensity:[grainDensityLine output]
                            AmplitudeOffset:[ampOffsetLine output]
                                PitchOffset:[pitchOffsetLine output] 
                              GrainDuration:[grainDurationLine output]  
                           MaxGrainDuration:ocsp(5) 
                              GrainFunction:fileTable 
                             WindowFunction:hamming 
                 IsRandomGrainFunctionIndex:NO];
        [self addOpcode:grainR];
        
        // AUDIO OUTPUT ========================================================
        
        OCSOutputStereo *stereoOutput = 
        [[OCSOutputStereo alloc] initWithInputLeft:[grainL output] 
                                        InputRight:[grainR output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}


@end

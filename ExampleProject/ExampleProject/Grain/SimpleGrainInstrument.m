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
#import "OCSExpSegment.h"
#import "OCSLine.h"
#import "OCSFileLength.h"
#import "OCSProperty.h"
#import "OCSGrain.h"
#import "OCSOutputStereo.h"

@implementation SimpleGrainInstrument

- (id)init 
{
    self = [super init];
    if (self) { 
        // INSTRUMENT DEFINITION ===============================================
        
        NSString * file = [[NSBundle mainBundle] pathForResource:@"beats" ofType:@"wav"];
        OCSSoundFileTable *fileTable = [[OCSSoundFileTable alloc] initWithFilename:file TableSize:16384];
        [self addFunctionTable:fileTable];
        
        
        OCSFunctionTable *hamming = [[OCSWindowsTable alloc] initWithSize:512 WindowType:kWindowHanning];
        [self addFunctionTable:hamming];
        
        OCSFileLength *fileLength = [[OCSFileLength alloc] initWithFunctionTable:fileTable];
        [self addOpcode:fileLength];
        
        OCSParamConstant *halfDuration = [OCSParamConstant paramWithFormat:@"%@ / 2", duration];
        
        OCSParamArray *amplitudeSegmentArray = [OCSParamArray paramArrayFromParams:halfDuration, ocsp(0.01), nil];
        OCSExpSegment *amplitudeExp = [[OCSExpSegment alloc] initWithFirstSegmentStartValue:ocsp(0.001) 
                                                                    FirstSegmentTargetValue:ocsp(0.1)
                                                                       FirstSegmentDuration:halfDuration
                                                                         DurationValuePairs:amplitudeSegmentArray];
        [self addOpcode:amplitudeExp];
        
        
        OCSParamConstant *baseFrequency  = [OCSParamConstant paramWithFormat:@"44100 / %@", fileLength];
        OCSParamConstant *finalFrequency = [OCSParamConstant paramWithFormat:@"0.8 * (%@)", baseFrequency];
        OCSLine * pitchLine = [[OCSLine alloc] initFromValue:baseFrequency
                                                     ToValue:finalFrequency
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
        
        
        OCSParamConstant *finalPitchOffset = [OCSParamConstant paramWithFormat:@"0.5 * (%@)", baseFrequency];
        OCSLine *pitchOffsetLine = [[OCSLine alloc] initFromValue:ocsp(0)
                                                          ToValue:finalPitchOffset
                                                         Duration:duration ];
        [pitchOffsetLine setOutput:[pitchOffsetLine control]];
        [self addOpcode:pitchOffsetLine];   
        
        OCSLine *grainDurationLine = [[OCSLine alloc] initFromValue:ocsp(0.1)
                                                            ToValue:ocsp(0.1)
                                                           Duration:duration];
        [grainDurationLine setOutput:[grainDurationLine control]];
        [self addOpcode:grainDurationLine];
        
        OCSGrain *grainL = [[OCSGrain alloc] initWithGrainFunction:fileTable  
                                                    WindowFunction:hamming 
                                                  MaxGrainDuration:ocsp(5) 
                                                         Amplitude:[amplitudeExp output] 
                                                        GrainPitch:[pitchLine output] 
                                                      GrainDensity:[grainDensityLine output] 
                                                     GrainDuration:[grainDurationLine control] 
                                             MaxAmplitudeDeviation:[ampOffsetLine control] 
                                                 MaxPitchDeviation:[pitchOffsetLine control] ];
        [self addOpcode:grainL];
        
        OCSGrain *grainR = [[OCSGrain alloc] initWithGrainFunction:fileTable  
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
        
        OCSOutputStereo *stereoOutput = [[OCSOutputStereo alloc] initWithLeftInput:[grainL output] 
                                                                        RightInput:[grainR output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}


@end

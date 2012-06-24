//
//  GrainBirds.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainBirds.h"
#import "OCSGrain.h"

@implementation GrainBirds
@synthesize grainDensity;
@synthesize grainDuration;
@synthesize pitchClass;
@synthesize pitchOffsetStartValue;
@synthesize pitchOffsetFirstTarget;
@synthesize reverbSend;

- (id)init
{
    self = [super init];
    if (self) {
        // INPUTS AND CONTROLS =================================================
        
        grainDensity            = [[OCSProperty alloc] init];
        grainDuration           = [[OCSProperty alloc] init];
        pitchClass              = [[OCSProperty alloc] init];
        pitchOffsetStartValue   = [[OCSProperty alloc] init];
        pitchOffsetFirstTarget  = [[OCSProperty alloc] init];
        reverbSend              = [[OCSProperty alloc] init];
        
        [grainDensity           setControl: [OCSParamControl  paramWithString:@"GrainDensity"]]; 
        [grainDuration          setControl: [OCSParamControl  paramWithString:@"GrainDuration"]];
        [pitchClass             setControl: [OCSParamControl  paramWithString:@"PitchClass"]]; 
        [pitchOffsetStartValue  setConstant:[OCSParamConstant paramWithString:@"PitchOffsetStartValue"]]; 
        [pitchOffsetFirstTarget setConstant:[OCSParamConstant paramWithString:@"PitchOffsetFirstTarget"]]; 
        [reverbSend             setConstant:[OCSParamConstant paramWithString:@"ReverbSend"]];
        
        [self addProperty:grainDensity];
        [self addProperty:grainDuration];
        [self addProperty:pitchClass];
        [self addProperty:pitchOffsetStartValue];
        [self addProperty:pitchOffsetFirstTarget];
        [self addProperty:reverbSend];
        
        // FUNCTIONS ===========================================================

        NSString * file = [[NSBundle mainBundle] pathForResource:@"a50" ofType:@"aif"];
        OCSSoundFileTable *fiftyHzSine = [[OCSSoundFileTable alloc] initWithFilename:file];
        [self addFunctionTable:fiftyHzSine];
        
        OCSWindowsTable *hanning = [[OCSWindowsTable alloc] initWithSize:4097 WindowType:kWindowHanning];
        [self addFunctionTable:hanning];
        
        // INSTRUMENT DEFINITION ===============================================
        
        // Useful times
        OCSParamConstant * tenthOfDuration = [OCSParamConstant paramWithFormat:@"%@ * 0.1", duration];
        OCSParamConstant * halfOfDuration  = [OCSParamConstant paramWithFormat:@"%@ * 0.5", duration];
        OCSParamConstant * sixthOfDuration = [OCSParamConstant paramWithFormat:@"%@ * 0.6", duration];
        
        
        OCSParamArray * amplitudeBreakpoints = [OCSParamArray paramArrayFromParams:sixthOfDuration, ocsp(6000), nil];

        OCSLineSegmentWithRelease * amplitude = 
        [[OCSLineSegmentWithRelease alloc] initWithFirstSegmentStartValue:ocsp(0.00001f)
                                                     FirstSegmentDuration:tenthOfDuration
                                                 FirstSegementTargetValue:ocsp(3000)
                                                             SegmentArray:amplitudeBreakpoints 
                                                          ReleaseDuration:tenthOfDuration
                                                               FinalValue:ocsp(0)];
        [self addOpcode:amplitude];
        
        OCSPitchClassToFreq * cpspch = [[OCSPitchClassToFreq alloc] initWithInput:[pitchClass output]];
        [self addOpcode:cpspch];
        
        OCSParamArray *pitchOffsetBreakpoints = [OCSParamArray paramArrayFromParams:
                                                 [OCSParamConstant paramWithFormat:@"%@ * 0.45", duration], 
                                                 ocsp(40), nil];
                                                  
        OCSLineSegmentWithRelease *pitchOffset = 
        [[OCSLineSegmentWithRelease alloc] initWithFirstSegmentStartValue:[pitchOffsetStartValue constant] 
                                                     FirstSegmentDuration:halfOfDuration
                                                 FirstSegementTargetValue:[pitchOffsetFirstTarget constant] 
                                                             SegmentArray:pitchOffsetBreakpoints 
                                                          ReleaseDuration:tenthOfDuration
                                                               FinalValue:ocsp(0)];
        [self addOpcode:pitchOffset];                         
        
        OCSGrain *grain = [[OCSGrain alloc] initWithAmplitude:[amplitude output] 
                                                        Pitch:[cpspch output] 
                                                 GrainDensity:[grainDensity control] 
                                              AmplitudeOffset:ocsp(1000)
                                                  PitchOffset:[pitchOffset output] 
                                                GrainDuration:[grainDuration control] 
                                             MaxGrainDuration:ocsp(0.1)
                                                GrainFunction:fiftyHzSine 
                                               WindowFunction:hanning   
                                   IsRandomGrainFunctionIndex:NO];
        [self addOpcode:grain];
        
        OCSFilterLowPassButterworth *butterlp = [[OCSFilterLowPassButterworth alloc] initWithInput:[grain output] 
                                                                                            Cutoff:ocsp(500)];
        [self addOpcode:butterlp];
        
        // AUDIO OUTPUT ========================================================
        
        
    }
    return self;
}

@end

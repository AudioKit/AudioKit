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

-(id)init
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
        
        [grainDensity           setOutput:[OCSParamControl  paramWithString:@"GrainDensity"]]; 
        [grainDuration          setOutput:[OCSParamControl  paramWithString:@"GrainDuration"]];
        [pitchClass             setOutput:[OCSParamControl  paramWithString:@"PitchClass"]]; 
        [pitchOffsetStartValue  setOutput:[OCSParamConstant paramWithString:@"PitchOffsetStartValue"]]; 
        [pitchOffsetFirstTarget setOutput:[OCSParamConstant paramWithString:@"PitchOffsetFirstTarget"]]; 
        [reverbSend             setOutput:[OCSParamConstant paramWithString:@"ReverbSend"]];
        
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
        
        OCSParamArray * amplitudeBreakpoints = [OCSParamArray paramArrayFromParams:
                                                [OCSParamConstant paramWithFormat:[OCSParamConstant paramWithFormat:@"%@ * 0.6", duration]], 
                                                [OCSParamConstant paramWithInt:6000], nil];

        OCSLineSegmentWithRelease * amplitude = 
        [[OCSLineSegmentWithRelease alloc] initWithFirstSegmentStartValue:[OCSParamConstant paramWithFloat:0.00001f]
                                                     FirstSegmentDuration:[OCSParamConstant paramWithFormat:@"%@ * 0.1", duration]
                                                 FirstSegementTargetValue:[OCSParamConstant paramWithInt:3000] 
                                                             SegmentArray:amplitudeBreakpoints 
                                                          ReleaseDuration:[OCSParamConstant paramWithFormat:@"%@ 0.1", duration] 
                                                               FinalValue:[OCSParamConstant paramWithInt:0] 
                                                                isControl:YES];
        [self addOpcode:amplitude];
        
        OCSPitchClassToFreq * cpspch = [[OCSPitchClassToFreq alloc] initWithInput:[pitchClass output]];
        [self addOpcode:cpspch];
        
        OCSParamArray *pitchOffsetBreakpoints = [OCSParamArray paramArrayFromParams:
                                                 [OCSParamConstant paramWithFormat:@"%@ * 0.45", duration], 
                                                 [OCSParamConstant paramWithInt:40], nil];
                                                  
        OCSLineSegmentWithRelease *pitchOffset = 
        [[OCSLineSegmentWithRelease alloc] initWithFirstSegmentStartValue:[pitchOffsetStartValue output] 
                                                     FirstSegmentDuration:[OCSParamConstant paramWithFormat:@"0.5 * %@", duration] 
                                                 FirstSegementTargetValue:[pitchOffsetFirstTarget output] 
                                                             SegmentArray:pitchOffsetBreakpoints 
                                                          ReleaseDuration:[OCSParamConstant paramWithFormat:@"%@ * 0.1", duration] 
                                                               FinalValue:[OCSParamConstant paramWithInt:0] 
                                                                isControl:YES];
        [self addOpcode:pitchOffset];                         
        
        OCSGrain *grain = [[OCSGrain alloc] initWithAmplitude:[amplitude output] 
                                                        Pitch:[cpspch output] 
                                                 GrainDensity:[grainDensity output] 
                                              AmplitudeOffset:[OCSParamConstant paramWithInt:1000]
                                                  PitchOffset:[pitchOffset output] 
                                                GrainDuration:[grainDuration output] 
                                             MaxGrainDuration:[OCSParamConstant paramWithFloat:0.1f] 
                                                GrainFunction:fiftyHzSine 
                                               WindowFunction:hanning   
                                   IsRandomGrainFunctionIndex:NO];
        [self addOpcode:grain];
        
        OCSFilterLowPassButterworth *butterlp = [[OCSFilterLowPassButterworth alloc] initWithInput:[grain output] 
                                                                                            Cutoff:[OCSParamConstant paramWithInt:500]];
        [self addOpcode:butterlp];
        
        // AUDIO OUTPUT ========================================================
        
        
    }
    return self;
}

@end

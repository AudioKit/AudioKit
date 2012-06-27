//
//  GrainBirds.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainBirds.h"
#import "OCSGrain.h"
#import "OCSAudio.h"

@interface GrainBirds () {
    OCSProperty *grainDensity;
    OCSProperty *grainDuration;
    OCSProperty *pitchClass;
    OCSProperty *pitchOffsetStartValue;
    OCSProperty *pitchOffsetFirstTarget;
    OCSProperty *reverbSend;
    
    OCSParam *auxilliaryOutput;
}
@end

@implementation GrainBirds
@synthesize grainDensity;
@synthesize grainDuration;
@synthesize pitchClass;
@synthesize pitchOffsetStartValue;
@synthesize pitchOffsetFirstTarget;
@synthesize reverbSend;
@synthesize auxilliaryOutput;

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
        
        [grainDensity setMinimumValue:.03];
        [grainDensity setMaximumValue:10000];
        
        [grainDuration setMinimumValue:.0004];
        [grainDuration setMaximumValue:.1];
        
        [pitchClass setMinimumValue:7.05];
        [pitchClass setMaximumValue:12.05];
        
        [pitchOffsetFirstTarget setMinimumValue:0];
        [pitchOffsetFirstTarget setMaximumValue:2000];
        [pitchOffsetStartValue setMinimumValue:0];
        [pitchOffsetStartValue setMaximumValue:2000];
        
        [reverbSend setMinimumValue:0.0];
        [reverbSend setMaximumValue:0.5];
        
        // FUNCTIONS ===========================================================
        
        NSString * file = [[NSBundle mainBundle] pathForResource:@"a50" ofType:@"aif"];
        OCSSoundFileTable *fiftyHzSine = [[OCSSoundFileTable alloc] initWithFilename:file TableSize:4096];
        [self addFunctionTable:fiftyHzSine];
        
        OCSWindowsTable *hanning = [[OCSWindowsTable alloc] initWithSize:4097 WindowType:kWindowHanning];
        [self addFunctionTable:hanning];
        
        // INSTRUMENT DEFINITION ===============================================
        
        // Useful times
        OCSParamConstant * tenthOfDuration           = [OCSParamConstant paramWithFormat:@"%@ * 0.1", duration];
        OCSParamConstant * fortyFivePercentDuration  = [OCSParamConstant paramWithFormat:@"%@ * 0.45", duration];
        OCSParamConstant * halfOfDuration            = [OCSParamConstant paramWithFormat:@"%@ * 0.5", duration];
        OCSParamConstant * sixthOfDuration           = [OCSParamConstant paramWithFormat:@"%@ * 0.6", duration];
        
        OCSSegmentArray * amplitude = 
        [[OCSSegmentArray alloc] initWithFirstSegmentStartValue:ocsp(0.00001f)
                                              FirstSegmentTargetValue:ocsp(500)
                                                 FirstSegmentDuration:tenthOfDuration];
        [amplitude addNextSegmentTargetValue:ocsp(1000) AfterDuration:sixthOfDuration];
        [amplitude addReleaseToFinalValue:ocsp(0) AfterDuration:tenthOfDuration];
        [self addOpcode:amplitude];
        
        OCSPitchClassToFreq * cpspch = [[OCSPitchClassToFreq alloc] initWithPitch:[pitchClass control]];
        [self addOpcode:cpspch];
        
        OCSSegmentArray *pitchOffset;
        pitchOffset = [[OCSSegmentArray alloc] initWithFirstSegmentStartValue:[pitchOffsetStartValue constant] 
                                                            FirstSegmentTargetValue:[pitchOffsetFirstTarget constant]
                                                               FirstSegmentDuration:halfOfDuration];
        [pitchOffset addNextSegmentTargetValue:ocsp(40) AfterDuration:fortyFivePercentDuration];
        [pitchOffset addReleaseToFinalValue:ocsp(0) AfterDuration:tenthOfDuration];
        [pitchOffset setOutput:[pitchOffset control]];
        [self addOpcode:pitchOffset];         
        
        OCSGrain *grain = [[OCSGrain alloc] initWithGrainFunction:hanning  
                                                   WindowFunction:fiftyHzSine 
                                                 MaxGrainDuration:ocsp(0.1)
                                                        Amplitude:[amplitude output] 
                                                       GrainPitch:[cpspch output] 
                                                     GrainDensity:[grainDensity control] 
                                                    GrainDuration:[grainDuration control] 
                                            MaxAmplitudeDeviation:ocsp(1000)
                                                MaxPitchDeviation:[pitchOffset control]];
        [self addOpcode:grain];
        
        OCSFilterLowPassButterworth *butterlp = [[OCSFilterLowPassButterworth alloc] initWithInput:[grain output] 
                                                                                   CutoffFrequency:ocsp(500)];
        [self addOpcode:butterlp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[butterlp output]];
        [self addOpcode:audio];
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSParam paramWithString:@"ToReverb"];
        [self assignOutput:auxilliaryOutput To:[OCSParam paramWithFormat:@"%@ + (%@ * %@)",
                                                auxilliaryOutput, [butterlp output], [reverbSend constant]]];
        
    }
    return self;
}

@end

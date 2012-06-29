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
#import "OCSWindowsTable.h"
#import "OCSSoundFileTable.h"
#import "OCSReverbSixParallelComb.h"
#import "OCSSegmentArray.h"
#import "OCSFilterLowPassButterworth.h"
#import "OCSGrain.h"

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
        OCSSoundFileTable *fiftyHzSine = [[OCSSoundFileTable alloc] initWithFilename:file tableSize:4096];
        [self addFunctionTable:fiftyHzSine];
        
        OCSWindowsTable *hanning = [[OCSWindowsTable alloc] initWithType:kWindowHanning
                                                                    size:4097];
        [self addFunctionTable:hanning];
        
        // INSTRUMENT DEFINITION ===============================================
        
        OCSSegmentArray * amplitude;
        amplitude = [[OCSSegmentArray alloc] initWithStartValue:ocsp(0.00001f)
                                                    toNextValue:ocsp(500)
                                                  afterDuration:[duration scaledBy:0.1]];
        [amplitude addValue:ocsp(1000) afterDuration:[duration scaledBy:0.6]];
        [amplitude addReleaseToFinalValue:ocsp(0) afterDuration:[duration scaledBy:0.1]];
        [self addOpcode:amplitude];

        OCSSegmentArray *pitchOffset;
        pitchOffset = [[OCSSegmentArray alloc] initWithStartValue:[pitchOffsetStartValue constant] 
                                                      toNextValue:[pitchOffsetFirstTarget constant]
                                                    afterDuration:[duration scaledBy:0.5]];
        [pitchOffset addValue:ocsp(40) afterDuration:[duration scaledBy:0.45]];
        [pitchOffset addReleaseToFinalValue:ocsp(0) afterDuration:[duration scaledBy:0.1]];
        [pitchOffset setOutput:[pitchOffset control]];
        [self addOpcode:pitchOffset];         
        
        OCSGrain *grain = [[OCSGrain alloc] initWithGrainFunction:hanning  
                                                   WindowFunction:fiftyHzSine 
                                                 MaxGrainDuration:ocsp(0.1)
                                                        Amplitude:[amplitude output] 
                                                   GrainFrequency:[[pitchClass control] toCPS]
                                                     GrainDensity:[grainDensity control] 
                                                    GrainDuration:[grainDuration control] 
                                            MaxAmplitudeDeviation:ocsp(1000)
                                                MaxPitchDeviation:[pitchOffset control]];
        [self addOpcode:grain];
        
        OCSFilterLowPassButterworth *butterlp;
        butterlp = [[OCSFilterLowPassButterworth alloc] initWithInput:[grain output] 
                                                      CutoffFrequency:ocsp(500)];
        [self addOpcode:butterlp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[butterlp output]];
        [self addOpcode:audio];
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSParam paramWithString:@"ToReverb"];
        [self assignOutput:auxilliaryOutput 
                        To:[OCSParam paramWithFormat:@"%@ + (%@ * %@)",
                            auxilliaryOutput, [butterlp output], [reverbSend constant]]];
        
    }
    return self;
}

@end

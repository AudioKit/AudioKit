//
//  GrainBirds.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainBirds.h"
#import "OCSGrain.h"
#import "OCSAudio.h"
#import "OCSWindowsTable.h"
#import "OCSSoundFileTable.h"
#import "OCSNReverb.h"
#import "OCSSegmentArray.h"
#import "OCSLowPassButterworthFilter.h"
#import "OCSGrain.h"

@interface GrainBirds () {
    OCSProperty *grainDensity;
    OCSProperty *grainDuration;
    OCSProperty *pitchClass;
    OCSProperty *pitchOffsetStartValue;
    OCSProperty *pitchOffsetFirstTarget;
    OCSProperty *reverbSend;
    
    OCSParameter *auxilliaryOutput;
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
        
        [grainDensity           setControl: [OCSControl  parameterWithString:@"GrainDensity"]]; 
        [grainDuration          setControl: [OCSControl  parameterWithString:@"GrainDuration"]];
        [pitchClass             setControl: [OCSControl  parameterWithString:@"PitchClass"]]; 
        [pitchOffsetStartValue  setConstant:[OCSConstant parameterWithString:@"PitchOffsetStartValue"]]; 
        [pitchOffsetFirstTarget setConstant:[OCSConstant parameterWithString:@"PitchOffsetFirstTarget"]]; 
        [reverbSend             setConstant:[OCSConstant parameterWithString:@"ReverbSend"]];
        
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
        [fiftyHzSine setIsNormalized:YES];
        [self addFTable:fiftyHzSine];
        
        OCSWindowsTable *hanning = [[OCSWindowsTable alloc] initWithType:kWindowHanning
                                                                    size:4097];
        [self addFTable:hanning];
        
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
                                                   windowFunction:fiftyHzSine 
                                                 maxGrainDuration:ocsp(0.1)
                                                        amplitude:[amplitude output] 
                                                   grainFrequency:[[pitchClass control] toCPS]
                                                     grainDensity:[grainDensity control] 
                                                    grainDuration:[grainDuration control] 
                                            maxAmplitudeDeviation:ocsp(1000)
                                                maxPitchDeviation:[pitchOffset control]];
        [self addOpcode:grain];
        
        OCSLowPassButterworthFilter *butterlp;
        butterlp = [[OCSLowPassButterworthFilter alloc] initWithInput:[grain output] 
                                                      cutoffFrequency:ocsp(500)];
        [self addOpcode:butterlp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[butterlp output]];
        [self addOpcode:audio];
        
        // EXTERNAL OUTPUTS ====================================================        
        // After your instrument is set up, define outputs available to others
        auxilliaryOutput = [OCSParameter parameterWithString:@"ToReverb"];
        [self assignOutput:auxilliaryOutput 
                        To:[OCSParameter parameterWithFormat:@"%@ + (%@ * %@)",
                            auxilliaryOutput, [butterlp output], [reverbSend constant]]];
        
    }
    return self;
}

@end

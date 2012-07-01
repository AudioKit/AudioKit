//
//  OCSSegmentArray.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSegmentArray.h"

@interface OCSSegmentArray () {
    NSString *opcode;
    OCSParamConstant *start;
    OCSParamConstant *dur;
    OCSParamConstant *target;
    NSMutableArray *segments;
    
    OCSParamConstant *release;
    OCSParamConstant *final;
    
    OCSParam *audio;
    OCSParamControl *control;
    OCSParam *output;
}
@end

@implementation OCSSegmentArray

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initWithStartValue:(OCSParamConstant *)firstSegmentStartValue
             toNextValue:(OCSParamConstant *)firstSegmentTargetValue
           afterDuration:(OCSParamConstant *)firstSegmentDuration
{
    self = [super init];
    
    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSParamControl paramWithString:[self opcodeName]];
        output  =  audio;
        
        opcode   = @"linseg";
        start    = firstSegmentStartValue;
        dur      = firstSegmentDuration;
        target   = firstSegmentTargetValue;
        segments = [[NSMutableArray alloc] init];
        release  = [OCSParamConstant paramWithInt:0];
        final    = [OCSParamConstant paramWithInt:0];
    }
    
    return self;
}

- (void)addValue:(OCSParamConstant *)nextSegmentTargetValue 
   afterDuration:(OCSParamConstant *)nextSegmentDuration;
{
    [segments addObject:nextSegmentDuration];
    [segments addObject:nextSegmentTargetValue];
}

- (void)addReleaseToFinalValue:(OCSParamConstant *)finalValue 
                 afterDuration:(OCSParamConstant *)releaseDuration
{
    // adds an r to the opcode
    if ([opcode isEqualToString:@"linseg"]) opcode = @"linsegr";
    if ([opcode isEqualToString:@"expseg"]) opcode = @"expsegr";
    release = releaseDuration;
    final   = finalValue;
}

- (void)useExponentialSegments {
    // Change the opcode name keeping the "r" intact.
    opcode = [opcode stringByReplacingOccurrencesOfString:@"linseg" withString:@"expseg"];
}

- (NSString *)stringForCSD
{
    if ([segments count] == 0) {
        if ([opcode isEqualToString:@"linseg"] || [opcode isEqualToString:@"expseg"]) {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@", 
                    output, opcode, start, dur, target];
        } else {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@, %@, %@", 
                    output, opcode, start, dur, target, release, final];
        }
    } else {
        NSMutableArray *s = [[NSMutableArray alloc] init];
        for (OCSParamConstant *value in segments) {
            [s addObject:[value parameterString]];
        }
        NSString *segs = [s componentsJoinedByString:@" , "];
       
        if ([opcode isEqualToString:@"linseg"] || [opcode isEqualToString:@"expseg"]) {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@, %@", 
                    output, opcode, start, dur, target, segs];
            
        } else {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@, %@, %@, %@", 
                    output, opcode, start, dur, target, segs, release, final];
        }
    }
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end

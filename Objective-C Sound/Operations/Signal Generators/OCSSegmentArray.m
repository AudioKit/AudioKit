//
//  OCSSegmentArray.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's linsegr and expsegr:
//  http://www.csounds.com/manual/html/linsegr.html
//  http://www.csounds.com/manual/html/expsegr.html
//

#import "OCSSegmentArray.h"

@interface OCSSegmentArray () {
    NSString *opcode;
    OCSConstant *start;
    OCSConstant *dur;
    OCSConstant *target;
    NSMutableArray *segments;
    
    OCSConstant *release;
    OCSConstant *final;
    
    OCSParameter *audio;
    OCSControl *control;
    OCSParameter *output;
}
@end

@implementation OCSSegmentArray

@synthesize control;
@synthesize output;

- (id)initWithStartValue:(OCSConstant *)firstSegmentStartValue
             toNextValue:(OCSConstant *)firstSegmentTargetValue
           afterDuration:(OCSConstant *)firstSegmentDuration
{
    self = [super init];
    
    if (self) {
        audio   = [OCSParameter parameterWithString:[self operationName]];
        control = [OCSControl parameterWithString:[self operationName]];
        output  =  audio;
        
        opcode   = @"linseg";
        start    = firstSegmentStartValue;
        dur      = firstSegmentDuration;
        target   = firstSegmentTargetValue;
        segments = [[NSMutableArray alloc] init];
        release  = [OCSConstant parameterWithInt:0];
        final    = [OCSConstant parameterWithInt:0];
    }
    
    return self;
}

- (void)addValue:(OCSConstant *)nextSegmentTargetValue 
   afterDuration:(OCSConstant *)nextSegmentDuration;
{
    [segments addObject:nextSegmentDuration];
    [segments addObject:nextSegmentTargetValue];
}

- (void)addReleaseToFinalValue:(OCSConstant *)finalValue 
                 afterDuration:(OCSConstant *)releaseDuration
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
        for (OCSConstant *value in segments) {
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
 
- (NSString *)description {
    return [output parameterString];
}

@end

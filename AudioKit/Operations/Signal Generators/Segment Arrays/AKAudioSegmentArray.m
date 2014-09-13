//
//  AKAudioSegmentArray.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's linsegr and expsegr:
//  http://www.csounds.com/manual/html/linsegr.html
//  http://www.csounds.com/manual/html/expsegr.html
//

#import "AKAudioSegmentArray.h"

@implementation AKAudioSegmentArray
{
    NSString *opcode;
    AKConstant *start;
    AKConstant *dur;
    AKConstant *target;
    NSMutableArray *segments;
    
    AKConstant *release;
    AKConstant *final;
}

- (instancetype)initWithStartValue:(AKConstant *)firstSegmentStartValue
                       toNextValue:(AKConstant *)firstSegmentTargetValue
                     afterDuration:(AKConstant *)firstSegmentDuration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        opcode   = @"linseg";
        start    = firstSegmentStartValue;
        dur      = firstSegmentDuration;
        target   = firstSegmentTargetValue;
        segments = [[NSMutableArray alloc] init];
        release  = akpi(0);
        final    = akpi(0);
    }
    
    return self;
}

- (void)addValue:(AKConstant *)nextSegmentTargetValue
   afterDuration:(AKConstant *)nextSegmentDuration;
{
    [segments addObject:nextSegmentDuration];
    [segments addObject:nextSegmentTargetValue];
}

- (void)addReleaseToFinalValue:(AKConstant *)finalValue
                 afterDuration:(AKConstant *)releaseDuration
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
                    self, opcode, start, dur, target];
        } else {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@, %@, %@",
                    self, opcode, start, dur, target, release, final];
        }
    } else {
        NSMutableArray *s = [[NSMutableArray alloc] init];
        for (AKConstant *value in segments) {
            [s addObject:[value parameterString]];
        }
        NSString *segs = [s componentsJoinedByString:@" , "];
        
        if ([opcode isEqualToString:@"linseg"] || [opcode isEqualToString:@"expseg"]) {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@, %@",
                    self, opcode, start, dur, target, segs];
            
        } else {
            return [NSString stringWithFormat:
                    @"%@ %@ %@, %@, %@, %@, %@, %@",
                    self, opcode, start, dur, target, segs, release, final];
        }
    }
}

@end

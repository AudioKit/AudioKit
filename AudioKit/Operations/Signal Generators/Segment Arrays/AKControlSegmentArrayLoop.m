//
//  AKControlSegmentArrayLoop.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/6/12
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's loopseg:
//  http://www.csounds.com/manual/html/loopseg.html
//

#import "AKControlSegmentArrayLoop.h"

@implementation AKControlSegmentArrayLoop
{
    NSString *opcode;
    AKControl *kfreq;
    AKControl *kvalue0;
    NSMutableArray *segments;
}

- (instancetype)initWithFrequency:(AKControl *)frequency
                       startValue:(AKControl *)startValue
{
    self = [super initWithString:[self operationName]];
    if (self) {
        opcode = @"loopseg";
        kfreq = frequency;
        kvalue0 = startValue;
        segments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addValue:(AKControl *)nextSegmentTargetValue
   afterDuration:(AKControl *)durationFraction;
{
    [segments addObject:durationFraction];
    [segments addObject:nextSegmentTargetValue];
}

- (void)useExponentialSegments {
    opcode = @"loopxseg";
}

- (NSString *)stringForCSD {
    if ([segments count] == 0) {
        return [NSString stringWithFormat:
                @"%@ %@ %@, 0, 0, %@",
                self, opcode, kfreq, kvalue0];
    } else {
        NSMutableArray *s = [[NSMutableArray alloc] init];
        for (AKControl *value in segments) {
            [s addObject:[value parameterString]];
        }
        NSString *segs = [s componentsJoinedByString:@" , "];
        return [NSString stringWithFormat:
                @"%@ %@ %@, 0, 0, %@, %@",
                self, opcode, kfreq, kvalue0, segs];
    }
}

@end
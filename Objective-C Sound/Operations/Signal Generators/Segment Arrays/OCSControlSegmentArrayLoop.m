//
//  OCSControlSegmentArrayLoop.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/6/12
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's loopseg:
//  http://www.csounds.com/manual/html/loopseg.html
//

#import "OCSControlSegmentArrayLoop.h"

@interface OCSControlSegmentArrayLoop () {
    NSString *opcode;
    OCSControl *kfreq;
    OCSControl *kvalue0;
    NSMutableArray *segments;
}
@end

@implementation OCSControlSegmentArrayLoop

- (instancetype)initWithFrequency:(OCSControl *)frequency
             startValue:(OCSControl *)startValue
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

- (void)addValue:(OCSControl *)nextSegmentTargetValue
   afterDuration:(OCSControl *)durationFraction;
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
        for (OCSControl *value in segments) {
            [s addObject:[value parameterString]];
        }
        NSString *segs = [s componentsJoinedByString:@" , "];
        return [NSString stringWithFormat:
                @"%@ %@ %@, 0, 0, %@, %@",
                self, opcode, kfreq, kvalue0, segs];
    }
}

@end
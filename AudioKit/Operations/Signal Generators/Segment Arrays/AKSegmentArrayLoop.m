//
//  AKSegmentArrayLoop.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/14/15
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's looptseg:
//  http://www.csounds.com/manual/html/looptseg.html
//

#import "AKSegmentArrayLoop.h"

@implementation AKSegmentArrayLoop
{
    AKParameter *loopFrequency;
    NSMutableArray<AKParameter *> *segments;
}

- (instancetype)initWithFrequency:(AKParameter *)frequency
                     initialValue:(AKParameter *)initialValue;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        loopFrequency = frequency;
        segments = [[NSMutableArray alloc] init];
        [segments addObject:initialValue];
        self.state = @"connectable";
        self.dependencies = @[loopFrequency, initialValue];
    }
    return self;
}

- (void)addValue:(AKParameter *)value
   afterDuration:(AKParameter *)duration
       concavity:(AKParameter *)concavity
{
    [segments addObject:concavity];
    [segments addObject:duration];
    [segments addObject:value];
    self.dependencies = [self.dependencies arrayByAddingObjectsFromArray:@[concavity, duration, value]];
}

- (NSString *)stringForCSD {
    NSMutableArray *convertedSegments = [NSMutableArray array];
    for (AKParameter *parameter in segments) {
        [convertedSegments addObject:[NSString stringWithFormat:@"AKControl(%@)", parameter]];
    }
    return [NSString stringWithFormat:
            @"%@ looptseg %@, 0, 0, %@",
            self,
            loopFrequency,
            [convertedSegments componentsJoinedByString:@", "]];
}

@end
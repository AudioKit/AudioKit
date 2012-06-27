//
//  LineSegmentWithRelease.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLineSegmentWithRelease.h"

@interface OCSLineSegmentWithRelease () {
    OCSParamControl *output;

    OCSParamConstant *start;
    OCSParamConstant *dur;
    OCSParamConstant *target;
    OCSParamArray *segments;
    
    OCSParamConstant *release;
    OCSParamConstant *final;
}
@end

@implementation OCSLineSegmentWithRelease

@synthesize output;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration
                  DurationValuePairs:(OCSParamArray *)durationValuePairs              
                     ReleaseDuration:(OCSParamConstant *)releaseDuration
                          FinalValue:(OCSParamConstant *)finalValue;
{
    self = [super init];
    if (self) {
        output   = [OCSParamControl paramWithString:[self opcodeName]];
        start    = firstSegmentStartValue;
        dur      = firstSegmentDuration;
        target   = firstSegmentTargetValue;
        segments = durationValuePairs;
        release  = releaseDuration;
        final    = finalValue;
    }
    
    return self;

}

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration               
                     ReleaseDuration:(OCSParamConstant *)releaseDuration
                          FinalValue:(OCSParamConstant *)finalValue;
{
    return [self initWithFirstSegmentStartValue:firstSegmentStartValue 
                        FirstSegmentTargetValue:firstSegmentTargetValue 
                           FirstSegmentDuration:firstSegmentDuration 
                             DurationValuePairs:nil 
                                ReleaseDuration:releaseDuration 
                                     FinalValue:finalValue];
}

-(NSString *)stringForCSD
{
    if (segments == nil) {
        return [NSString stringWithFormat:@"%@ linsegr %@, %@, %@, %@, %@\n", 
                output, start, dur, target, release, final];
    } else {
        return [NSString stringWithFormat:@"%@ linsegr %@, %@, %@, %@, %@, %@\n", 
                output, start, dur, target, [segments parameterString], release, final];
    }
}

-(NSString *) description {
    return [output parameterString];
}

@end

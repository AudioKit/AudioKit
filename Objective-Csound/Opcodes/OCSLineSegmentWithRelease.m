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
    OCSParamConstant *firstSegmentStartValue;
    OCSParamConstant *firstSegmentDuration;
    OCSParamConstant *firstSegmentTargetValue;
    OCSParamArray *segmentArray;
    
    OCSParamConstant *releaseDuration;
    OCSParamConstant *finalValue;
}
@end

@implementation OCSLineSegmentWithRelease
@synthesize output;

-(id)initWithFirstSegmentStartValue:(OCSParamConstant *)start
               FirstSegmentDuration:(OCSParamConstant *)dur
           FirstSegementTargetValue:(OCSParamConstant *)targ
                       SegmentArray:(OCSParamArray *)aSegmentArray
                    ReleaseDuration:(OCSParamConstant *)releaseDur
                         FinalValue:(OCSParamConstant *)finalVal
{
    self = [super init];
    if (self) {
        output = [OCSParamControl paramWithString:[self opcodeName]];
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
        segmentArray            = aSegmentArray;
        releaseDuration         = releaseDur;
        finalValue              = finalVal;
    }
    
    return self;

}

-(id)initWithSegmentStartValue:(OCSParamConstant *)start
               SegmentDuration:(OCSParamConstant *)dur
           SegementTargetValue:(OCSParamConstant *)targ
               ReleaseDuration:(OCSParamConstant *)releaseDur
                    FinalValue:(OCSParamConstant *)finalVal;
{
    if (self) {
        output = [OCSParamControl paramWithString:[self opcodeName]];
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
        releaseDuration         = releaseDur;
        finalValue              = finalVal;
    }
    
    return self;
}

-(NSString *)stringForCSD
{
    if (segmentArray == nil) {
        return [NSString stringWithFormat:@"%@ linsegsg %@, %@, %@, %@, %@\n", 
                output, 
                firstSegmentStartValue, 
                firstSegmentDuration, 
                firstSegmentTargetValue,
                releaseDuration,
                finalValue];
    } else {
        return [NSString stringWithFormat:@"%@ linsegr %@, %@, %@, %@, %@, %@\n", 
                output, 
                firstSegmentStartValue, 
                firstSegmentDuration, 
                firstSegmentTargetValue, 
                [segmentArray parameterString],
                releaseDuration,
                finalValue];
    }
}

-(NSString *) description {
    return [output parameterString];
}

@end

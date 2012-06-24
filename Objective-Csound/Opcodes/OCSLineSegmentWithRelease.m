//
//  LineSegmentWithRelease.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLineSegmentWithRelease.h"

@implementation OCSLineSegmentWithRelease
@synthesize output;

-(id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                       SegmentArray:(OCSParamArray *)aSegmentArray
                    ReleaseDuration:(OCSParamConstant *)releaseDur
                         FinalValue:(OCSParamConstant *)finalVal
                          isControl:(BOOL)control
{
    self = [super init];
    if (self) {
        if (control) {
            output = [OCSParamControl paramWithString:[self opcodeName]];
        } else {
            output = [OCSParam paramWithString:[self opcodeName]];
        }

        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
        segmentArray            = aSegmentArray;
        releaseDuration         = releaseDur;
        finalValue              = finalVal;
    }
    
    return self;

}

-(id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                    ReleaseDuration:(OCSParamConstant *)releaseDur
                         FinalValue:(OCSParamConstant *)finalVal 
                          isControl:(BOOL)control
{
    if (self) {
        if (control) {
            output = [OCSParamControl paramWithString:[self opcodeName]];
        } else {
            output = [OCSParam paramWithString:[self opcodeName]];
        }
        
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
        releaseDuration         = releaseDur;
        finalValue              = finalVal;
    }
    
    return self;
}

-(NSString *)convertToCsd
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

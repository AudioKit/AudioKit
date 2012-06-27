//
//  OCSLinearSegmentArray.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLinearSegmentArray.h"

@interface OCSLinearSegmentArray () {
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

@implementation OCSLinearSegmentArray

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration
{
    self = [super init];
    
    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSParamControl paramWithString:[self opcodeName]];
        output  =  audio;
        
        start    = firstSegmentStartValue;
        dur      = firstSegmentDuration;
        target   = firstSegmentTargetValue;
        segments = [[NSMutableArray alloc] init];
        release  = [OCSParamConstant paramWithInt:0];
        final    = [OCSParamConstant paramWithInt:0];
    }
    
    return self;
}

- (void)addNextSegmentTargetValue:(OCSParamConstant *)nextSegmentTargetValue 
                    AfterDuration:(OCSParamConstant *)nextSegmentDuration 
{
    [segments addObject:nextSegmentDuration];
    [segments addObject:nextSegmentTargetValue];
}

- (void)addReleaseToFinalValue:(OCSParamConstant *)finalValue 
                 AfterDuration:(OCSParamConstant *)releaseDuration
{
    release = releaseDuration;
    final   = finalValue;
}

//- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
//             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
//                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration
//                  DurationValuePairs:(OCSParamArray *)durationValuePairs;
//{
//    self = [super init];
//    
//    if (self) {
//        output   = [OCSParamControl paramWithString:[self opcodeName]];
//        start    = firstSegmentStartValue;
//        dur      = firstSegmentDuration;
//        target   = firstSegmentTargetValue;
//        segments = durationValuePairs;
//    }
//    
//    return self;
//}
//
//- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
//             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
//                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration;
//{
//    return [self initWithFirstSegmentStartValue:firstSegmentStartValue
//                        FirstSegmentTargetValue:firstSegmentTargetValue 
//                           FirstSegmentDuration:firstSegmentDuration 
//                             DurationValuePairs:nil];
//}

- (NSString *)stringForCSD
{    
    if ([segments count] == 0) {
        return [NSString stringWithFormat:
                @"%@ linsegr %@, %@, %@, %@, %@\n", 
                output, start, dur, target, release, final];
    } else {
        NSMutableArray *s = [[NSMutableArray alloc] init];
        for (OCSParamConstant *value in segments) {
            [s addObject:[value parameterString]];
        }
        NSString *segs = [s componentsJoinedByString:@" , "];
       
        return [NSString stringWithFormat:
                @"%@ linsegr %@, %@, %@, %@, %@, %@\n", 
                output, start, dur, target, segs, release, final];
    }
}

- (NSString *)description {
    return [output parameterString];
}

@end

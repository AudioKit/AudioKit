//
//  OCSExpSegment.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSExpSegment : OCSOpcode
{
    OCSParamConstant *firstSegmentStartValue;
    OCSParamConstant *firstSegmentDuration;
    OCSParamConstant *firstSegmentTargetValue;
    OCSParamArray *segmentArray;
    
    OCSParamControl *output;
}

@property (nonatomic, strong) OCSParamControl *output;


- (id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                       SegmentArray:(OCSParamArray *)aSegmentArray;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ;

@end

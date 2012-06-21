//
//  CSDExpSegment.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDExpSegment : CSDOpcode
{
    CSDParamControl * output;
}

@property (nonatomic, strong) CSDParamControl * output;
@property (nonatomic, strong) CSDParamConstant *firstSegmentStartValue;
@property (nonatomic, strong) CSDParamConstant *firstSegmentDuration;
@property (nonatomic, strong) CSDParamConstant *firstSegmentTargetValue;
@property (nonatomic, strong) CSDParamArray *segmentArray;

-(id)initWithFirstSegmentStartValue:(CSDParamConstant *) start
               FirstSegmentDuration:(CSDParamConstant *) dur
           FirstSegementTargetValue:(CSDParamConstant *) targ
                       SegmentArray:(CSDParamArray *)aSegmentArray;

-(id)initWithFirstSegmentStartValue:(CSDParamConstant *) start
               FirstSegmentDuration:(CSDParamConstant *) dur
           FirstSegementTargetValue:(CSDParamConstant *) targ;

@end

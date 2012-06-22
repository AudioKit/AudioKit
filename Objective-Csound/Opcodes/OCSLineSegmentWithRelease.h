//
//  LineSegmentWithRelease.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSLineSegmentWithRelease : OCSOpcode {
    OCSParamControl * output;
    OCSParamConstant * firstSegmentStartValue;
    OCSParamConstant * firstSegmentDuration;
    OCSParamConstant * firstSegmentTargetValue;
    OCSParamArray *segmentArray;
    
    OCSParamConstant * releaseDuration;
    OCSParamConstant * finalValue;
}
@property (nonatomic, strong) OCSParamControl * output;

-(id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                       SegmentArray:(OCSParamArray *)aSegmentArray
                    ReleaseDuration:(OCSParamConstant *)releaseDur
                         FinalValue:(OCSParamConstant *)finalVal
                          isControl:(BOOL)control;

-(id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                    ReleaseDuration:(OCSParamConstant *)releaseDur
                         FinalValue:(OCSParamConstant *)finalVal
                          isControl:(BOOL)control;


@end

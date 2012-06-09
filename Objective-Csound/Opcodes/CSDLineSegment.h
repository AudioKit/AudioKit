//
//  CSDLineSegment.h
//  ExampleProject
//
//  Description:
//  Trace a series of line segments between specified points.
//
//  Unlike several other linear and exponential generators CSDLineSegment 
//  holds the final value if the sum of segment durations is less than the 
//  note duration.
//  
//  Csd Representation:
//  ares linseg ia, idur1, ib [, idur2] [, ic] [...]
//  kres linseg ia, idur1, ib [, idur2] [, ic] [...]
//

//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDParam.h"
#import "CSDParamArray.h"

@interface CSDLineSegment : CSDOpcode
@property (nonatomic, strong) CSDParam *firstSegmentStartValue;
@property (nonatomic, strong) CSDParam *firstSegmentDuration;
@property (nonatomic, strong) CSDParam *firstSegmentTargetValue;
@property (nonatomic, strong) CSDParamArray *segmentArray;

-(NSString *)convertToCsd;

-(id)initWithIFirstSegmentStartValue:(CSDParam *) aStart
               iFirstSegmentDuration:(CSDParam *) aDuration
           iFirstSegementTargetValue:(CSDParam *) aTarget
                        SegmentArray:(CSDParamArray *)aSegmentArray;

-(id)initWithIFirstSegmentStartValue:(CSDParam *) aStart
               iFirstSegmentDuration:(CSDParam *) aDuration
           iFirstSegementTargetValue:(CSDParam *) aTarget;

@end

//
//  OCSConstants.h
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#ifndef ExampleProject_OCSConstants_h
#define ExampleProject_OCSConstants_h

extern NSString *const FINAL_OUTPUT;


typedef enum
{
    kRandomDistributionUniform=1,
    kRandomDistributionLinear=2,
    kRandomDistributionTriangular=3,
    kRandomDistributionExponential=4,
    kRandomDistributionBiexponential=5,
    kRandomDistributionGaussian=6,
    kRandomDistributionCauchy=7,
    kRandomDistributionPositiveCauchy=8,
    kRandomDistributionBeta=9,
    kRandomDistributionWeibull=10,
    kRandomDistributionPoisson=11
}RandomDistributionType;

#endif

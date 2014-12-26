//
//  AKRandomDistributionTable.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKRandomDistributionTable.h"

@implementation AKRandomDistributionTable

- (instancetype)initType:(AKRandomDistributionType)distributionType
                    size:(int)size;
{
    return [self initType:distributionType size:size level:1.0];
}

- (instancetype)initType:(AKRandomDistributionType)distributionType
                    size:(int)size
                   level:(float)level;
{
    return [self initWithType:AKFunctionTableTypeRandomDistributions
                         size:size
                   parameters:[AKArray arrayFromConstants:
                               akpi(distributionType), akp(level), nil]];
}

- (instancetype)initWeibullTypeWithSize:(int)size
                                  level:(float)level
                                  sigma:(float)sigma;
{
    int distributionType = 10;
    return [self initWithType:AKFunctionTableTypeRandomDistributions
                         size:size
                   parameters:[AKArray arrayFromConstants:
                               akpi(distributionType), level, akp(sigma), nil]];
}

- (instancetype)initBetaTypeWithSize:(int)size
                               level:(float)level
                               alpha:(float)alpha
                                beta:(float)beta;
{
    int distributionType = 9;
    return [self initWithType:AKFunctionTableTypeRandomDistributions
                         size:size
                   parameters:[AKArray arrayFromConstants:
                               akpi(distributionType), level, akp(alpha), akp(beta), nil]];
}

@end

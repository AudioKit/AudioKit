//
//  OCSRandomDistributionTable.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSRandomDistributionTable.h"

@implementation OCSRandomDistributionTable

- (instancetype)initType:(RandomDistributionType)distributionType
                    size:(int)size;
{
    return [self initType:distributionType size:size level:1.0];
}

- (instancetype)initType:(RandomDistributionType)distributionType
                    size:(int)size
                   level:(float)level;
{
    return [self initWithType:kFTRandomDistributions
                         size:size
                   parameters:[OCSArray arrayFromConstants:
                               ocspi(distributionType), ocsp(level), nil]];
}

- (instancetype)initWeibullTypeWithSize:(int)size
                                  level:(float)level
                                  sigma:(float)sigma;
{
    int distributionType = 10;
    return [self initWithType:kFTRandomDistributions
                         size:size
                   parameters:[OCSArray arrayFromConstants:
                               ocspi(distributionType), level, ocsp(sigma), nil]];
}

- (instancetype)initBetaTypeWithSize:(int)size
                               level:(float)level
                               alpha:(float)alpha
                                beta:(float)beta;
{
    int distributionType = 9;
    return [self initWithType:kFTRandomDistributions
                         size:size
                   parameters:[OCSArray arrayFromConstants:
                               ocspi(distributionType), level, ocsp(alpha), ocsp(beta), nil]];
}


@end

//
//  OCSRandomDistributionTable.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSRandomDistributionTable.h"

@implementation OCSRandomDistributionTable

- (id)initType:(RandomDistributionType)distributionType
          size:(int)size;
{
    return [self initType:distributionType size:size level:ocsp(1)];
}

- (id)initType:(RandomDistributionType)distributionType
          size:(int)size
         level:(float)level;
{
    return [self initWithType:kFTRandomDistributions
                         size:size
                   parameters:[OCSParameterArray paramArrayFromParams:
                               ocspi(distributionType), level, nil]];
}

- (id)initWeibullTypeWithSize:(int)size
                        level:(float)level
                        sigma:(float)sigma;
{
    int distributionType = 10;
    return [self initWithType:kFTRandomDistributions
                         size:size
                   parameters:[OCSParameterArray paramArrayFromParams:
                               ocspi(distributionType), level, ocsp(sigma), nil]];
}

- (id)initBetaTypeWithSize:(int)size
                     level:(float)level
                     alpha:(float)alpha
                      beta:(float)beta;
{
    int distributionType = 9;
    return [self initWithType:kFTRandomDistributions
                         size:size
                   parameters:[OCSParameterArray paramArrayFromParams:
                               ocspi(distributionType), level, ocsp(alpha), ocsp(beta), nil]]; 
}


@end

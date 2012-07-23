//
//  OCSRandomDistributionTable.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFTable.h"

/** Generates tables of different random distributions.
 */

@interface OCSRandomDistributionTable : OCSFTable

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
    kRandomDistributionPoisson=11
}RandomDistributionType;

- (id)initType:(RandomDistributionType)distributionType
           size:(int)size;

- (id)initType:(RandomDistributionType)distributionType
           size:(int)size
          level:(float)level;

- (id)initWeibullTypeWithSize:(int)size
                        level:(float)level
                        sigma:(float)sigma;

- (id)initBetaTypeWithSize:(int)size
                        level:(float)level
                        alpha:(float)alpha
                      beta:(float)beta;

@end

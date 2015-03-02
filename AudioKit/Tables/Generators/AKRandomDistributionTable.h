//
//  AKRandomDistributionTable.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFunctionTable.h"

/** Generates tables of different random distributions.
 */

@interface AKRandomDistributionTable : AKFunctionTable

/// Create a random distribution table
/// @param distributionType Type of distribution to use (note that Beta and Weibull use their own init methods).
/// @param size             Size of the table.
- (instancetype)initType:(AKRandomDistributionType)distributionType
                    size:(int)size;

/// Create a random distribution table
/// @param distributionType Type of distribution to use (note that Beta and Weibull use their own init methods).
/// @param size             Size of the table.
/// @param level            Level is the maximum amplitude of the signal varying from 0 to level or -level to level depending on the type.
- (instancetype)initType:(AKRandomDistributionType)distributionType
                    size:(int)size
                   level:(float)level;

/// Create a random distribution table of the Weibull type.
/// @param size  Size of the table.
/// @param level Level is the maximum amplitude of the signal varying from 0 to level or -level to level depending on the type.
/// @param sigma Value that determines the spread of the distribution.
- (instancetype)initWeibullTypeWithSize:(int)size
                                  level:(float)level
                                  sigma:(float)sigma;

/// Create a random distribution table of the Beta type.
/// @param size  Size of the table.
/// @param level Level is the maximum amplitude of the signal varying from 0 to level or -level to level depending on the type.
/// @param alpha If alpha is smaller than one, smaller values favor values near 0.
/// @param beta  If beta is smaller than one, smaller values favor values near level.
- (instancetype)initBetaTypeWithSize:(int)size
                               level:(float)level
                               alpha:(float)alpha
                                beta:(float)beta;

@end

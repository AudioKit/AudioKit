//
//  AKRandomDistributionTableGenerator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKTableGenerator.h"

/** Generates tables of different random distributions.
 */

@interface AKRandomDistributionTableGenerator : AKTableGenerator

/// Create random numbers with a uniform (positive numbers only) distribution
- (instancetype)initUniformDistribution;

/// Create random numbers with a uniform (positive numbers only) distribution
+ (instancetype)uniformDistribution;

/// Create random numbers with a linear (positive numbers only) distribution
- (instancetype)initLinearDistribution;

/// Create random numbers with a linear (positive numbers only) distribution
+ (instancetype)linearDistribution;

/// Create random numbers with a triangular (positive and negative numbers) distribution
- (instancetype)initTriangularDistribution;

/// Create random numbers with a triangular (positive and negative numbers) distribution
+ (instancetype)triangularDistribution;

/// Create random numbers with a exponential (positive numbers only) distribution
- (instancetype)initExponentialDistribution;

/// Create random numbers with a exponential (positive numbers only) distribution
+ (instancetype)exponentialDistribution;

/// Create random numbers with a biexponential (positive and negative numbers) distribution
- (instancetype)initBiexponentialDistribution;

/// Create random numbers with a biexponential (positive and negative numbers) distribution
+ (instancetype)biexponentialDistribution;

/// Create random numbers with a Gaussian (positive and negative numbers) distribution
- (instancetype)initGaussianDistribution;

/// Create random numbers with a Gaussian (positive and negative numbers) distribution
+ (instancetype)gaussianDistribution;

/// Create random numbers with a Cauchy (positive and negative numbers) distribution
- (instancetype)initCauchyDistribution;

/// Create random numbers with a Cauchy (positive and negative numbers) distribution
+ (instancetype)cauchyDistribution;

/// Create random numbers with a positive Cauchy (positive numbers only) distribution
- (instancetype)initPositiveCauchyDistribution;

/// Create random numbers with a positive Cauchy (positive numbers only) distribution
+ (instancetype)positiveCauchyDistribution;

/// Create random numbers with a Poisson (positive numbers only) distribution
- (instancetype)initPoissonDistribution;

/// Create random numbers with a Poisson (positive numbers only) distribution
+ (instancetype)poissonDistribution;

/// Create a random distribution table of the Weibull type.
/// @param sigma Value that determines the spread of the distribution.
- (instancetype)initWeibullDistributionWithSigma:(float)sigma;

/// Create a random distribution table of the Weibull type.
/// @param sigma Value that determines the spread of the distribution.
+ (instancetype)weibullDistributionWithSigma:(float)sigma;

/// Create a random distribution table of the Beta (positive numbers only) type. If both alpha and beta equal one we have uniform distribution. If both alpha and beta are greater than one we have a sort of Gaussian distribution.
/// @param alpha If alpha is smaller than one, smaller values favor values near 0.
/// @param beta  If beta is smaller than one, smaller values favor values near level.
- (instancetype)initBetaDistributionWithAlpha:(float)alpha
                                         beta:(float)beta;

/// Create a random distribution table of the Beta (positive numbers only) type. If both alpha and beta equal one we have uniform distribution. If both alpha and beta are greater than one we have a sort of Gaussian distribution.
/// @param alpha If alpha is smaller than one, smaller values favor values near 0.
/// @param beta  If beta is smaller than one, smaller values favor values near level.
+ (instancetype)betaDistributionWithAlpha:(float)alpha
                                     beta:(float)beta;

@end

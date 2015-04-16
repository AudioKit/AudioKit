//
//  AKRandomDistributionTableGenerator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/24/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKRandomDistributionTableGenerator.h"

@implementation AKRandomDistributionTableGenerator {
    int type;
    float _sigma;
    float _alpha;
    float _beta;
}

- (int)generationRoutineNumber {
    return -21;
}

- (instancetype)initWithType:(int)distributionType
{
    self = [super init];
    if (self) type = distributionType;
    return self;
}

- (instancetype)initUniformDistribution {
    return [self initWithType:1];
}

+ (instancetype)uniformDistribution {
    return [[self alloc] initUniformDistribution];
}

- (instancetype)initLinearDistribution {
    return [self initWithType:2];
}

+ (instancetype)linearDistribution {
    return [[self alloc] initLinearDistribution];
}

- (instancetype)initTriangularDistribution{
    return [self initWithType:3];
}

+ (instancetype)triangularDistribution {
    return [[self alloc] initTriangularDistribution];
}

- (instancetype)initExponentialDistribution {
    return [self initWithType:4];
}

+ (instancetype)exponentialDistribution {
    return [[self alloc] initExponentialDistribution];
}

- (instancetype)initBiexponentialDistribution {
    return [self initWithType:5];
}

+ (instancetype)biexponentialDistribution {
    return [[self alloc] initBiexponentialDistribution];
}

- (instancetype)initGaussianDistribution {
    return [self initWithType:6];
};

+ (instancetype)gaussianDistribution {
    return [[self alloc] initGaussianDistribution];
}

- (instancetype)initCauchyDistribution {
    return [self initWithType:7];
}

+ (instancetype)cauchyDistribution {
    return [[self alloc] initCauchyDistribution];
}

- (instancetype)initPositiveCauchyDistribution {
    return [self initWithType:8];
}

+ (instancetype)positiveCauchyDistribution {
    return [[self alloc] initPositiveCauchyDistribution];
}

- (instancetype)initPoissonDistribution {
    return [self initWithType:11];
}

+ (instancetype)poissonDistribution {
    return [[self alloc] initPoissonDistribution];
}

- (instancetype)initWeibullDistributionWithSigma:(float)sigma
{
    self = [super init];
    if (self) {
        type = 10;
        _sigma = sigma;
    }
    return self;
}

+ (instancetype)weibullDistributionWithSigma:(float)sigma {
    return [[self alloc]initWeibullDistributionWithSigma:sigma];
}

- (instancetype)initBetaDistributionWithAlpha:(float)alpha
                                         beta:(float)beta
{
    self = [super init];
    if (self) {
        type = 9;
        _alpha = alpha;
        _beta = beta;
    }
    return self;
}

+ (instancetype)betaDistributionWithAlpha:(float)alpha
                                     beta:(float)beta
{
    return [[self alloc] initBetaDistributionWithAlpha:alpha beta:beta];
}

- (NSArray *)parametersWithSize:(NSUInteger)size
{
    if (type == 9) {
        return @[@(type), @(_alpha), @(_beta)];
    } else if (type == 10) {
        return @[@(type), @(_sigma)];
    } else {
        return @[@(type)];
    }
}

@end

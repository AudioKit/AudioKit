//
//  AKNoise.m
//  AudioKit
//
//  Auto-generated on 2/13/15.
//  Customized by Aurelius Prochazka on 2/13/15
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's noisepinky:
//  http://www.csounds.com/manual/html/noisepinky.html
//

#import "AKNoise.h"
#import "AKManager.h"

@implementation AKNoise

- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                      pinkBalance:(AKParameter *)pinkBalance
                             beta:(AKParameter *)beta
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _amplitude = amplitude;
        _pinkBalance = pinkBalance;
        _beta = beta;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _amplitude = akp(1);
        _pinkBalance = akp(0);
        _beta = akp(0);
    }
    return self;
}

+ (instancetype)noise
{
    return [[AKNoise alloc] init];
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalPinkBalance:(AKParameter *)pinkBalance {
    _pinkBalance = pinkBalance;
}
- (void)setOptionalBeta:(AKParameter *)beta {
    _beta = beta;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    
    [csdString appendFormat:@"aWhiteNoise noise %@, ", _amplitude];
    
    if ([_beta class] == [AKControl class]) {
        [csdString appendFormat:@"%@\n", _beta];
    } else {
        [csdString appendFormat:@"AKControl(%@)\n", _beta];
    }
    
    [csdString appendFormat:
     @"%@ = (1-%@) * aWhiteNoise + %@ * pinkish(aWhiteNoise, 1)\n",
     self, _pinkBalance, _pinkBalance];
    
    return csdString;
}

@end

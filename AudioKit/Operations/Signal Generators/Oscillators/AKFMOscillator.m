//
//  AKFMOscillator.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's foscili:
//  http://www.csounds.com/manual/html/foscili.html
//

#import "AKFMOscillator.h"
#import "AKManager.h"

@implementation AKFMOscillator

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                        baseFrequency:(AKParameter *)baseFrequency
                    carrierMultiplier:(AKParameter *)carrierMultiplier
                 modulatingMultiplier:(AKParameter *)modulatingMultiplier
                      modulationIndex:(AKParameter *)modulationIndex
                            amplitude:(AKParameter *)amplitude
                                phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _baseFrequency = baseFrequency;
        _carrierMultiplier = carrierMultiplier;
        _modulatingMultiplier = modulatingMultiplier;
        _modulationIndex = modulationIndex;
        _amplitude = amplitude;
        _phase = phase;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _functionTable = [AKManager standardSineTable];
    
        _baseFrequency = akp(440);
        _carrierMultiplier = akp(1);
        _modulatingMultiplier = akp(1);
        _modulationIndex = akp(1);
        _amplitude = akp(0.5);
        _phase = akp(0);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKFMOscillator alloc] init];
}

- (void)setOptionalFunctionTable:(AKFunctionTable *)functionTable {
    _functionTable = functionTable;
}
- (void)setOptionalBaseFrequency:(AKParameter *)baseFrequency {
    _baseFrequency = baseFrequency;
}
- (void)setOptionalCarrierMultiplier:(AKParameter *)carrierMultiplier {
    _carrierMultiplier = carrierMultiplier;
}
- (void)setOptionalModulatingMultiplier:(AKParameter *)modulatingMultiplier {
    _modulatingMultiplier = modulatingMultiplier;
}
- (void)setOptionalModulationIndex:(AKParameter *)modulationIndex {
    _modulationIndex = modulationIndex;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ foscili ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    if ([_baseFrequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _baseFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _baseFrequency];
    }

    [csdString appendFormat:@"%@, ", _carrierMultiplier];
    
    [csdString appendFormat:@"%@, ", _modulatingMultiplier];
    
    if ([_modulationIndex isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _modulationIndex];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _modulationIndex];
    }

    [csdString appendFormat:@"%@, ", _functionTable];
    
    [csdString appendFormat:@"%@", _phase];
    return csdString;
}

@end

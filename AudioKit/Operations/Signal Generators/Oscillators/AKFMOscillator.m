//
//  AKFMOscillator.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
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
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _baseFrequency = baseFrequency;
        _carrierMultiplier = carrierMultiplier;
        _modulatingMultiplier = modulatingMultiplier;
        _modulationIndex = modulationIndex;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _functionTable = [AKManager standardSineWave];
    
        _baseFrequency = akp(440);
        _carrierMultiplier = akp(1);
        _modulatingMultiplier = akp(1);
        _modulationIndex = akp(1);
        _amplitude = akp(0.5);
    }
    return self;
}

+ (instancetype)oscillator
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

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_phase = akp(-1);        
    [csdString appendFormat:@"%@ foscili ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    if ([_baseFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _baseFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _baseFrequency];
    }

    [csdString appendFormat:@"%@, ", _carrierMultiplier];
    
    [csdString appendFormat:@"%@, ", _modulatingMultiplier];
    
    if ([_modulationIndex class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _modulationIndex];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _modulationIndex];
    }

    [csdString appendFormat:@"%@, ", _functionTable];
    
    [csdString appendFormat:@"%@", _phase];
    return csdString;
}

@end

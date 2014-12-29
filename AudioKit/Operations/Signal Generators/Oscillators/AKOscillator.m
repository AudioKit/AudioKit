//
//  AKOscillator.m
//  AudioKit
//
//  Auto-generated on 12/29/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillator.h"
#import "AKManager.h"

@implementation AKOscillator

- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                            frequency:(AKParameter *)frequency
                            amplitude:(AKParameter *)amplitude
                                phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _functionTable = functionTable;
        _frequency = frequency;
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
        _functionTable = [AKManager standardSineWave];
    
        _frequency = akp(440);
        _amplitude = akp(1);
        _phase = akp(0);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKOscillator alloc] init];
}

- (void)setOptionalFunctionTable:(AKFunctionTable *)functionTable {
    _functionTable = functionTable;
}
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ oscili ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    [csdString appendFormat:@"%@, ", _frequency];
    
    [csdString appendFormat:@"%@, ", _functionTable];
    
    [csdString appendFormat:@"%@", _phase];
    return csdString;
}

@end
